global function MpWeaponKunaiR99_Init
global function OnWeaponActivate_R101
global function OnWeaponDeactivate_R101
global function OnWeaponPrimaryAttack_R101

global function OnWeaponActivate_kunai_R99
global function OnWeaponDeactivate_kunai_R99

const asset KUNAIR99_FX_GLOW_FP = $"P_kunai_idle_FP"
const asset KUNAIR99_FX_GLOW_3P = $"P_kunai_idle_3P"

void function MpWeaponKunaiR99_Init()
{
	PrecacheParticleSystem( KUNAIR99_FX_GLOW_FP )
	PrecacheParticleSystem( KUNAIR99_FX_GLOW_3P )
}

void function OnWeaponActivate_kunai_R99( entity weapon )
{
	//printt( "mp_weapon_wraith_kunai_primary activated" )
	if ( weapon.HasMod( "kunailauncher" ) )
	{
		weapon.PlayWeaponEffect( KUNAIR99_FX_GLOW_FP, KUNAIR99_FX_GLOW_3P, "shell" )
		// weapon.PlayWeaponEffect( KUNAIR99_FX_GLOW_FP, KUNAIR99_FX_GLOW_3P, "vent_cover_L" )
		// weapon.PlayWeaponEffect( KUNAIR99_FX_GLOW_FP, KUNAIR99_FX_GLOW_3P, "vent_cover_R" )
		weapon.PlayWeaponEffect( KUNAIR99_FX_GLOW_FP, KUNAIR99_FX_GLOW_3P, "muzzle_flash" )
	}
}

void function OnWeaponDeactivate_kunai_R99( entity weapon )
{
	//printt( "mp_weapon_wraith_kunai_primary deactivated" )
	weapon.StopWeaponEffect( KUNAIR99_FX_GLOW_FP, KUNAIR99_FX_GLOW_3P )
}

//--------------------------------------------------
// R101 MAIN
//--------------------------------------------------

void function OnWeaponActivate_R101( entity weapon )
{
	OnWeaponActivate_weapon_basic_bolt( weapon )

	OnWeaponActivate_RUIColorSchemeOverrides( weapon )
	OnWeaponActivate_ReactiveKillEffects( weapon )
}

void function OnWeaponDeactivate_R101( entity weapon )
{
	OnWeaponDeactivate_ReactiveKillEffects( weapon )
}

var function OnWeaponPrimaryAttack_R101( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( weapon.HasMod( "altfire_highcal" ) )
		thread PlayDelayedShellEject( weapon, RandomFloatRange( 0.03, 0.04 ) )

	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}
