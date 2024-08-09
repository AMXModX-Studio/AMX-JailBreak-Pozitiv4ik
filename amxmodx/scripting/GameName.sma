#include <amxmodx>
#include <fakemeta>


public plugin_init() register_forward(FM_GetGameDescription, "GameName");

public GameName()
{
	forward_return(FMV_STRING, "» CS-ESCAPE.RU");
	return FMRES_SUPERCEDE;
}