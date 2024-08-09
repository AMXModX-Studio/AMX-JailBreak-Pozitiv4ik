#include <amxmodx>
#include <amxmisc>

#define TIMER 10 //Каждые N секунд будет отображаться Tutor Message

#define MAXMESSAGE 150
#define TASK_HIDE_TUTOR 98123

new g_iTotalMessage, g_szMessage[MAXMESSAGE][180], g_iStyle[MAXMESSAGE], g_iSound[MAXMESSAGE]
new g_iMsgTutorClose, g_iMsgTutorText, g_iMaxPlayers, g_iCurrentMessage = 0

public plugin_init()
{	
	register_plugin("Tutor Manager", "1.0", "Dorus")
	
	g_iMsgTutorClose = get_user_msgid("TutorClose")
	g_iMsgTutorText = get_user_msgid("TutorText")
	
	g_iMaxPlayers = get_maxplayers()
	
	set_task(float(TIMER), "show_tutor_message", _, _, _, "b")
}

public plugin_precache()
{
	precache_generic("gfx/career/icon_!.tga")
	precache_generic("gfx/career/icon_!-bigger.tga")
	precache_generic("gfx/career/icon_i.tga")
	precache_generic("gfx/career/icon_i-bigger.tga")
	precache_generic("gfx/career/icon_skulls.tga")
	precache_generic("gfx/career/round_corner_ne.tga")
	precache_generic("gfx/career/round_corner_nw.tga")
	precache_generic("gfx/career/round_corner_se.tga")
	precache_generic("gfx/career/round_corner_sw.tga")

	precache_generic("resource/TutorScheme.res")
	precache_generic("resource/UI/TutorTextWindow.res")
	
	precache_sound("events/tutor_msg.wav")
	
	load_from_file()
}

public client_putinserver(id)
{
	if(task_exists(id+TASK_HIDE_TUTOR))
		remove_task(id+TASK_HIDE_TUTOR)
}

public show_tutor_message(iTask)
{
	static id
	
	if(g_iCurrentMessage >= g_iTotalMessage)
		g_iCurrentMessage = 0
	
	for(id = 1; id <= g_iMaxPlayers; id++)
	{
		if(!is_user_connected(id))
			continue
		
		Create_TutorMsg(id, g_szMessage[g_iCurrentMessage], g_iStyle[g_iCurrentMessage], g_iSound[g_iCurrentMessage])
	}
	
	g_iCurrentMessage++
}

stock Create_TutorMsg(id, szMsg[], iStyle, iSound)
{
	if(iSound == 1)
		emit_sound(id, CHAN_ITEM, "events/tutor_msg.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	message_begin(MSG_ONE_UNRELIABLE , g_iMsgTutorClose, {0, 0, 0}, id)
	message_end()

	message_begin(MSG_ONE_UNRELIABLE , g_iMsgTutorText, {0, 0, 0}, id)
	write_string(szMsg)
	write_byte(0)
	write_short(0)
	write_short(0)
	write_short(1<<iStyle)
	message_end()
	
	if(task_exists(id+TASK_HIDE_TUTOR))
		remove_task(id+TASK_HIDE_TUTOR)
	
	set_task(5.0, "Remove_TutorMsg", id+TASK_HIDE_TUTOR)
}

public Remove_TutorMsg(iTask)
{
	static id
	id = iTask - TASK_HIDE_TUTOR
	
	if(!is_user_connected(id))
		return
	
	message_begin(MSG_ONE_UNRELIABLE , g_iMsgTutorClose, {0, 0, 0}, id)
	message_end()
}

public load_from_file()
{
	new szConfigsDir[100], szBuffer[180]
	g_iTotalMessage = 0
	get_localinfo("amxx_configsdir", szConfigsDir, charsmax(szConfigsDir))
	formatex(szConfigsDir, charsmax(szConfigsDir), "%s/tutor_messages.ini", szConfigsDir)
	
	if(!file_exists(szConfigsDir))
	{
		log_amx("ERROR! File '%s' not found!", szConfigsDir)
		return
	}
	
	new szLineData[600], szBufferStyle[10], szBufferSound[10], iFile = fopen(szConfigsDir, "rt")
	
	while(iFile && !feof(iFile))
	{
		fgets(iFile, szLineData, charsmax(szLineData))
		
		if(szLineData[0] != '"') continue
		
		parse(szLineData, szBuffer, charsmax(szBuffer), szBufferStyle, charsmax(szBufferStyle), szBufferSound, charsmax(szBufferSound))
		
		g_iStyle[g_iTotalMessage] = str_to_num(szBufferStyle)
		g_iSound[g_iTotalMessage] = str_to_num(szBufferSound)
		
		utf8Tocp1251(szBuffer, g_szMessage[g_iTotalMessage], charsmax(g_szMessage[]))
		
		g_iTotalMessage++
		
		if(g_iTotalMessage >= MAXMESSAGE)
		{
			log_amx("ERROR! Max tutor message!")
			g_iTotalMessage--
			break
		}
	}
	
	if(iFile)
		fclose(iFile)
}

stock utf8Tocp1251(const string[], output[], maxlen)
{
    new i, len, j, char1, char2
    len = strlen(string)
    while(string[i] && j <= maxlen)
    {
        if (i + 1 < len)
        {
            char1 = string[i]&0xFF
            char2 = string[i+1]&0xFF
            if (char1 == 0xD0 && char2 == 0x81)
            {
                output[j] = 168
                i++
            }
            else
            if (char1 == 0xD1 && char2 == 0x91)
            {
                output[j] = 184
                i++
            }
            else
            if (char1 == 0xD0 && char2 >= 0x90 && char2 <= 0xBF)
            {
                output[j] = char2 + 48
                i++
            }
            else
            if (char1 == 0xD1 && char2 >= 0x80 && char2 <= 0x8F)
            {
                output[j] = char2 + 112
                i++
            }
            else
                output[j] = string[i]
        }
        else
            output[j] = string[i]
        i++
        j++
    }
    
    output[maxlen] = 0;
}