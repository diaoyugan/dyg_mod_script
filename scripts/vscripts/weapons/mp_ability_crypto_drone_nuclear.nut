#if(true)//

global function MpAbilityCryptoDronenuclear_Init
global function OnWeaponAttemptOffhandSwitch_ability_crypto_drone_nuclear
global function OnWeaponPrimaryAttack_ability_crypto_drone_nuclear
#if SERVER
global function DroneFirenuclear
#endif



// struct
// {
// 	#if CLIENT
// 	int colorCorrection
// 	int screenFxHandle
// 	#endif 
// } file

void function MpAbilityCryptoDronenuclear_Init()
{


	PrecacheParticleSystem( TITAN_NUCLEAR_CORE_FX_3P )
	PrecacheParticleSystem( TITAN_NUCLEAR_CORE_FX_1P )
	PrecacheParticleSystem( TITAN_NUCLEAR_CORE_NUKE_FX )

}

#if SERVER



void function DroneFirenuclear( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	entity camera = GetPlayerCamera( owner )
	
	// Shouldn't have happened, give their ult charge back!
	if( !IsValid( camera ) )
	{
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
		return
	}
	if( !IsValid( owner ) || !owner.IsPlayer() )
		return
	
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( owner ), Loadout_CharacterClass() )
	string charRef = ItemFlavor_GetHumanReadableRef( character )

	if( charRef == "character_crypto")
		PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_super" )

	camera.Anim_Play( "drone_EMP" )


	thread DroneFirenuclear_Thread( weapon, camera )
}





void function DroneFirenuclear_Thread( entity weapon, entity camera )
{
	entity soul = weapon.GetWeaponOwner()
	table e = {}
	e.titan <- camera
	e.team <- camera.GetTeam()

	e.player <- null
	e.npcPilot <- null
	if ( camera.IsPlayer() )
		e.player = camera

		e.nukeFX <- []
		e.attacker <-  null
		e.inflictor <-  null
		e.damageSourceId <- -1
		e.damageTypes <- null
		e.overrideAttacker <- null

	thread NuclearCoreExplosion( camera.GetOrigin(), e, weapon )
}

#endif
#if SERVER
void function NuclearCoreExplosion( vector origin, table e ,entity weapon )
{
	entity titan = expect entity( e.titan )

	// e.needToClearNukeFX = false //This thread and NuclearCoreExplosionChainReaction now take responsibility for clearing the FX

	// OnThreadEnd(
	// 	function() : ( e )
	// 	{
	// 		ClearNuclearBlueSunEffect( e )
	// 	}
	// )

	wait 1.3
	Assert( IsValid( titan ) )
	titan.Die()

	EmitSoundAtPosition( titan.GetTeam(), origin, "titan_nuclear_death_explode" )

	// titan.noLongerCountsForLTS <- true

	thread NuclearCoreExplosionChainReaction( origin, e, weapon )

	if ( IsAlive( titan ) )
		titan.Die( null, null, { scriptType = DF_EXPLOSION, damageType = DMG_REMOVENORAGDOLL, damageSourceId = null } )
}

void function NuclearCoreExplosionChainReaction( vector origin, table e, entity weapon )
{
	int explosions
	int innerRadius
	float time
	bool IsNPC

	float heavyArmorDamage = 2500
	float normalDamage = 2500

	switch ( 4 )
	{
		case 4:
			// npc nuke: the idea is to be the same as the regular nuke - but with less explosion calls
			explosions = 3
			innerRadius = 350
			time = 1.5 //1 is the regular nuke time - but we won't be adding an extra explosion and we want 3 explosions over 1s. This will mathematically give us that.
			IsNPC = true

			float fraction = 10.0 / explosions //10 is the regular nuke number
			 heavyArmorDamage = heavyArmorDamage * fraction
			 normalDamage = normalDamage * fraction
		break
	}

	float waitPerExplosion = time / explosions

	// ClearNuclearBlueSunEffect( e )


		PlayFX( TITAN_NUCLEAR_CORE_FX_3P, origin + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0))
		PlayFX( TITAN_NUCLEAR_CORE_FX_3P, origin + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0))

		PlayFX( TITAN_NUCLEAR_CORE_FX_3P, origin + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0))


	// one extra explosion that does damage to physics entities at smaller radius
	if ( !IsNPC )
		explosions += 1

	int outerRadius

	float baseNormalDamage 		= normalDamage
	float baseHeavyArmorDamage 	= heavyArmorDamage
	int baseInnerRadius 		= innerRadius
	int baseOuterRadius 		= outerRadius

	// all damage must have an inflictor currently
	entity inflictor = CreateEntity( "script_ref" )
	inflictor.SetOrigin( origin )
	inflictor.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	DispatchSpawn( inflictor )

	OnThreadEnd(
		function() : ( inflictor )
		{
			if ( IsValid( inflictor ) )
				inflictor.Destroy()
		}
	)

	for ( int i = 0; i < explosions; i++ )
	{
		 normalDamage 		= baseNormalDamage
		 heavyArmorDamage 	= baseHeavyArmorDamage
		 innerRadius 		= baseInnerRadius
		 outerRadius 		= baseOuterRadius

		if ( i == 0 && !IsNPC )
		{
			normalDamage = 75
			heavyArmorDamage = 0
			outerRadius = 600
		}
		else
		{
			outerRadius = 750
		}

		entity explosionOwner = (weapon.GetWeaponOwner())

		if ( outerRadius < innerRadius )
			outerRadius = innerRadius

		RadiusDamage_DamageDef( damagedef_nuclear_core,
			origin,								// origin
			explosionOwner,						// owner
			inflictor,							// inflictor
			normalDamage,						// normal damage
			heavyArmorDamage,					// heavy armor damage
			innerRadius,						// inner radius
			outerRadius,						// outer radius
			0 )									// dist from attacker

		wait waitPerExplosion
	}
}
#endif
bool function OnWeaponAttemptOffhandSwitch_ability_crypto_drone_nuclear( entity weapon )
{
	int ammoReq = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()
	if ( player.IsPhaseShifted() )
		return false

	if ( StatusEffect_GetSeverity( player, eStatusEffect.crypto_has_camera ) == 0.0 )
	{
		#if CLIENT
		AddPlayerHint( 1.0, 0.25, $"rui/hud/tactical_icons/tactical_crypto", "#CRYPTO_ULTIMATE_CAMERA_NOT_READY" )
		#endif
		return false
	}

	if ( StatusEffect_GetSeverity( player, eStatusEffect.crypto_camera_is_recalling ) > 0.0 )
	{
		//
		return false
	}

	return true
}

var function OnWeaponPrimaryAttack_ability_crypto_drone_nuclear( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( StatusEffect_GetSeverity( weaponOwner, eStatusEffect.crypto_has_camera ) == 0.0 )
		return 0

#if SERVER
	DroneFirenuclear( weapon )
#endif

	PlayerUsedOffhand( weaponOwner, weapon )

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}
#endif