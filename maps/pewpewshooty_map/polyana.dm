#if !defined(using_map_DATUM)

	#include "../shared/exodus_torch/_include.dm"

	#include "polyana_announcements.dm"
	#include "polyana_areas.dm"


	//CONTENT
	#include "../shared/job/jobs.dm"
	#include "../shared/datums/uniforms.dm"
	#include "../shared/items/cards_ids.dm"
	#include "../shared/items/clothing.dm"
	#include "polyana_gamemodes.dm"
	#include "polyana_presets.dm"
	#include "polyana_shuttles.dm"

	#include "polyana.dmm"


	#include "../shared/exodus_torch/_include.dm"

	#include "../../code/modules/lobby_music/museum.dm"
	#include "../../code/modules/lobby_music/absconditus.dm"
	#include "../../code/modules/lobby_music/space_oddity.dm"
	#include "../../code/modules/lobby_music/undercurrent.dm"
	#include "../../code/modules/lobby_music/conquer.dm"
	#include "../../code/modules/lobby_music/generic_songs.dm"
	#include "../../code/modules/lobby_music/docking.dm"

	#define using_map_DATUM /datum/map/hospital

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring polyana
#endif
