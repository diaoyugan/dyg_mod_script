global function MpMeleeHeal_Init

void function MpMeleeHeal_Init()
{
    #if SERVER
    AddDamageCallbackSourceID( eDamageSourceId.melee_bloodhound_axe , bloodhound_Axe_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.melee_bolo_sword , bolo_sword_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.melee_lifeline_baton , lifeline_baton_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.melee_shadowsquad_hands , shadowsquad_hands_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.melee_wraith_kunai , wraith_kunai_DamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.melee_pilot_emptyhanded , pilot_emptyhanded_DamagedTarget )
    #endif
}

void function bloodhound_Axe_DamagedTarget(entity target, var damageInfo)
{
    //entity weapon      = DamageInfo_GetWeapon( damageInfo ) // This returns null for melee. See R5DEV-28611.
	entity weapon = null
    entity owner = DamageInfo_GetAttacker( damageInfo )
//    weapon.AddMod("melee_heal")
#if SERVER
if ( owner == target )
{
    DamageInfo_SetDamage( damageInfo, 0 )
    return
}
if ( owner.GetTeam() == target.GetTeam() )
{
    DamageInfo_SetDamage( damageInfo, 0 )
return
}
else if ( target.IsNPC() || target.IsPlayer() )
{
    thread healSelf( owner, weapon )
}
#endif
}


void function pilot_emptyhanded_DamagedTarget(entity target, var damageInfo)
{
    //entity weapon      = DamageInfo_GetWeapon( damageInfo ) // This returns null for melee. See R5DEV-28611.
	entity weapon = null
    entity owner = DamageInfo_GetAttacker( damageInfo )
//    weapon.AddMod("melee_heal")
#if SERVER
if ( owner == target )
{
    DamageInfo_SetDamage( damageInfo, 0 )
    return
}
if ( owner.GetTeam() == target.GetTeam() )
{
    DamageInfo_SetDamage( damageInfo, 0 )
return
}
else if ( target.IsNPC() || target.IsPlayer() )
{
    thread healSelf( owner, weapon )
}
#endif
}


void function bolo_sword_DamagedTarget(entity target, var damageInfo)
{
    //entity weapon      = DamageInfo_GetWeapon( damageInfo ) // This returns null for melee. See R5DEV-28611.
	entity weapon = null
    entity owner = DamageInfo_GetAttacker( damageInfo )
//    weapon.AddMod("melee_heal")
#if SERVER
if ( owner == target )
{
    DamageInfo_SetDamage( damageInfo, 0 )
    return
}
if ( owner.GetTeam() == target.GetTeam() )
{
    DamageInfo_SetDamage( damageInfo, 0 )
return
}
else if ( target.IsNPC() || target.IsPlayer() )
{
    thread healSelf( owner, weapon )
}
#endif
}



void function lifeline_baton_DamagedTarget(entity target, var damageInfo)
{
    //entity weapon      = DamageInfo_GetWeapon( damageInfo ) // This returns null for melee. See R5DEV-28611.
	entity weapon = null
    entity owner = DamageInfo_GetAttacker( damageInfo )
//    weapon.AddMod("melee_heal")
#if SERVER
if ( owner == target )
{
    DamageInfo_SetDamage( damageInfo, 0 )
    return
}
if ( owner.GetTeam() == target.GetTeam() )
{
    DamageInfo_SetDamage( damageInfo, 0 )
return
}
else if ( target.IsNPC() || target.IsPlayer() )
{
    thread healSelf( owner, weapon )
}
#endif
}



void function shadowsquad_hands_DamagedTarget(entity target, var damageInfo)
{
    //entity weapon      = DamageInfo_GetWeapon( damageInfo ) // This returns null for melee. See R5DEV-28611.
	entity weapon = null
    entity owner = DamageInfo_GetAttacker( damageInfo )
//    weapon.AddMod("melee_heal")
#if SERVER
if ( owner == target )
{
    DamageInfo_SetDamage( damageInfo, 0 )
    return
}
if ( owner.GetTeam() == target.GetTeam() )
{
    DamageInfo_SetDamage( damageInfo, 0 )
return
}
else if ( target.IsNPC() || target.IsPlayer() )
{
    thread healSelf( owner, weapon )
}
#endif
}



void function wraith_kunai_DamagedTarget(entity target, var damageInfo)
{
    //entity weapon      = DamageInfo_GetWeapon( damageInfo ) // This returns null for melee. See R5DEV-28611.
	entity weapon = null
    entity owner = DamageInfo_GetAttacker( damageInfo )
//    weapon.AddMod("melee_heal")
#if SERVER
if ( owner == target )
{
    DamageInfo_SetDamage( damageInfo, 0 )
    return
}
if ( owner.GetTeam() == target.GetTeam() )
{
    DamageInfo_SetDamage( damageInfo, 0 )
return
}
else if ( target.IsNPC() || target.IsPlayer() )
{
    thread healSelf( owner, weapon )
}
#endif
}


#if SERVER
void function healSelf( entity owner, entity weapon )
{


//    int heal = weapon.GetWeaponSettingInt( eWeaponVar.melee_damage )
    int heal             = 30
    int currentShields   = owner.GetShieldHealth()
    int currentHealth    = owner.GetHealth()
    int shieldsHealthMax = owner.GetShieldHealthMax()
    int healthMax        = 100

    //全满什么都不干
    if ((currentShields == shieldsHealthMax) && ( currentHealth == healthMax ))
    {
    }

    //盾量已满 生命溢出 也就是溢出部分作废
    else if ((currentShields == shieldsHealthMax) && ( currentHealth + heal > healthMax ))
    {
        owner.SetHealth( healthMax )
    }
    
    //盾量不满生命溢出 也就是溢出部分回盾
    else if ((currentShields < shieldsHealthMax) && ( currentHealth + heal > healthMax ))
    {
        int overflowHeal = ((currentHealth + heal) - healthMax)

        if (currentShields + overflowHeal > shieldsHealthMax) //如果回盾以后造成盾量溢出 使其设为最大值而不要溢出
        {
        owner.SetShieldHealth( shieldsHealthMax )
        owner.SetHealth( healthMax )
        }
        else                                                        //回盾以后没有造成盾量溢出 使其正常恢复溢出值
        owner.SetShieldHealth( currentShields + overflowHeal )
        owner.SetHealth( healthMax )
    }


    //盾量已满 生命未满 回盾
    else if ((currentShields == shieldsHealthMax) && ( (currentHealth + heal) < healthMax ))
    {
        owner.SetHealth( (currentHealth + heal) )
    }

    //盾量溢出生命全满 设盾量为最大值
    else if (((currentShields + heal) > shieldsHealthMax) && ( currentHealth == healthMax ))
    {
        owner.SetShieldHealth(shieldsHealthMax)
    }

    //盾量不满生命全满 回盾
    else if (((currentShields + heal) < shieldsHealthMax) && ( currentHealth == healthMax ))
    {
        owner.SetShieldHealth((currentShields + heal))
    }

    //都不满 先回血
    else if (((currentShields + heal) < shieldsHealthMax) && ( (currentHealth + heal) < healthMax ))
    {
        owner.SetHealth( (currentHealth + heal) )
    }

}
#endif