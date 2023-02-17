global function MpArmorPiercingHopup_Init


void function MpArmorPiercingHopup_Init()
{
#if SERVER
    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_autopistol , RE45_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_r97 , R99_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_pdw , Prowler_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_alternator_smg , Alternator_DamagedTarget )
#endif
}

void function RE45_DamagedTarget(entity target, var damageInfo)
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
    entity attacker = DamageInfo_GetAttacker( damageInfo )
#if SERVER
    if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}
	if ( attacker.GetTeam() == target.GetTeam() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
        return
    }
    else if ( target.IsNPC() || target.IsPlayer() )
    {
        thread Penetratingdamage( target, weapon, attacker, damageInfo )
        // printt("1")
    }
#endif
}

void function Alternator_DamagedTarget(entity target, var damageInfo)
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
    entity attacker = DamageInfo_GetAttacker( damageInfo )
#if SERVER
    if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}
	if ( attacker.GetTeam() == target.GetTeam() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
        return
    }
    else if ( target.IsNPC() || target.IsPlayer() )
    {
        thread Penetratingdamage( target, weapon, attacker, damageInfo )
        // printt("1")
    }
#endif
}

void function R99_DamagedTarget(entity target, var damageInfo)
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
    entity attacker = DamageInfo_GetAttacker( damageInfo )
#if SERVER
    if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}
	if ( attacker.GetTeam() == target.GetTeam() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
        return
    }
    else if ( target.IsNPC() || target.IsPlayer() )
    {
        thread Penetratingdamage( target, weapon, attacker, damageInfo )
        // printt("1")
    }
#endif
}

void function Prowler_DamagedTarget(entity target, var damageInfo)
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
    entity attacker = DamageInfo_GetAttacker( damageInfo )
#if SERVER
    if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}
	if ( attacker.GetTeam() == target.GetTeam() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
        return
    }
    else if ( target.IsNPC() || target.IsPlayer() )
    {
        thread Penetratingdamage( target, weapon, attacker, damageInfo )
    }
#endif
}

void function Penetratingdamage( entity target, entity weapon, entity attacker, var damageInfo )
{
    #if SERVER
    if (weapon.HasMod("armor_piercing"))
    {
        int targetShields = target.GetShieldHealth()
        int targetHealth = target.GetHealth()
        int penetratDamage = (weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value ) / 2)


        if  (targetShields > 0)
        {
            target.TakeDamage( penetratDamage, attacker, weapon, { scriptType = DF_BYPASS_SHIELD } )
             printt("[DEBUG]penetratDamage"+ penetratDamage)
        }

    }
    #endif
}