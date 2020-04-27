#if !defined(using_map_DATUM)

	#include "polyana_announcements.dm"
	#include "polyana_areas.dm"
	#include "polyana_define.dm"
	#include "polyana_unit_testing.dm"


	//CONTENT
	#include "../shared/job/jobs.dm"
	#include "../shared/datums/uniforms.dm"
	#include "../shared/items/cards_ids.dm"
	#include "../shared/items/clothing.dm"
	#include "polyana_gamemodes.dm"
	#include "polyana_shuttles.dm"

	#include "polyana-1.dmm"
	#include "polyana-2.dmm"

	#include "../shared/exodus_torch/_include.dm"

	#include "../../code/modules/lobby_music/museum.dm"
	#include "../../code/modules/lobby_music/absconditus.dm"
	#include "../../code/modules/lobby_music/space_oddity.dm"
	#include "../../code/modules/lobby_music/undercurrent.dm"
	#include "../../code/modules/lobby_music/conquer.dm"
	#include "../../code/modules/lobby_music/generic_songs.dm"
	#include "../../code/modules/lobby_music/docking.dm"

	#define using_map_DATUM /datum/map/polyana

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring polyana
#endif
