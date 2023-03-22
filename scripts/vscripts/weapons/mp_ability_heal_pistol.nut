global function MpAbilityHealPistol_Init
global function OnWeaponActive_ability_heal_pistol
global function OnWeaponDeactivate_ability_heal_pistol



void function OnWeaponActive_ability_heal_pistol( entity weapon )
{
    #if SERVER
    entity owner = weapon.GetWeaponOwner()
	SetTeamIsRabid( owner.GetTeam(), true )
    #endif
    #if CLIENT
	AddPlayerHint( 3.0, 0.5, $"rui/weapon_icons/r5/weapon_wingman", "使用此技能期间你的小队会开启友军伤害" )
	#endif
}



void function OnWeaponDeactivate_ability_heal_pistol( entity weapon )
{
    #if SERVER
    entity owner = weapon.GetWeaponOwner()
	SetTeamIsRabid( owner.GetTeam(), false )
    #endif
}


void function MpAbilityHealPistol_Init()
{
    #if SERVER
    AddDamageCallbackSourceID( eDamageSourceId.mp_ability_heal_pistol, HandleDamageSource )
    #endif
}


void function HandleDamageSource( entity target, var damageInfo )
{
    printt("heal_pistol_callbacked")
    
	entity weapon = DamageInfo_GetWeapon( damageInfo )
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    printt(attacker.GetTeam())
    printt(target.GetTeam())
    #if SERVER
	if ( attacker.GetTeam() == target.GetTeam() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
        //没错 打中队友了 给他回血
        thread HealTeammate( target, weapon )
        return
    }
    else if (( attacker.GetTeam() != target.GetTeam() ) || (target.IsNPC()))
    {
		DamageInfo_SetDamage( damageInfo, 0 )
        //打中人敌人总不能还扣能量吧
        thread GiveChargeBack( weapon )
		return
    }
#endif
}

void function GiveChargeBack( entity weapon )
{
    //老规矩 不要溢出 因为鬼知道会不会崩溃
    int chargemax = weapon.GetWeaponPrimaryClipCountMax()
    int currentcharge = weapon.GetWeaponPrimaryClipCount() 
    int givechargebackcount = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )

    if (( currentcharge < chargemax ) && ((currentcharge + givechargebackcount) < chargemax))
    {
	weapon.SetWeaponPrimaryClipCount( currentcharge + givechargebackcount )
	return
    }
    else if (((currentcharge + givechargebackcount) >= chargemax))
    {
    weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
    return
    }
}
#if SERVER
void function HealTeammate( entity target, entity weapon )
{
    int heal             = 45
    int currentShields   = target.GetShieldHealth()
    int currentHealth    = target.GetHealth()
    int shieldsHealthMax = target.GetShieldHealthMax()
    int healthMax        = 100

    //全满什么都不干 顺便返还能量
    if ((currentShields == shieldsHealthMax) && ( currentHealth == healthMax ))
    {
        thread GiveChargeBack( weapon )
    }

    //盾量已满 生命溢出 也就是溢出部分作废
    else if ((currentShields == shieldsHealthMax) && ( currentHealth + heal > healthMax ))
    {
        target.SetHealth( healthMax )
    }
    
    //盾量不满生命溢出 也就是溢出部分回盾
    else if ((currentShields < shieldsHealthMax) && ( currentHealth + heal > healthMax ))
    {
        int overflowHeal = ((currentHealth + heal) - healthMax)

        if (currentShields + overflowHeal > shieldsHealthMax) //如果回盾以后造成盾量溢出 使其设为最大值而不要溢出
        {
        target.SetShieldHealth( shieldsHealthMax )
        target.SetHealth( healthMax )
        }
        else                                                        //回盾以后没有造成盾量溢出 使其正常恢复溢出值
        target.SetShieldHealth( currentShields + overflowHeal )
        target.SetHealth( healthMax )
    }


    //盾量已满 生命未满 回盾
    else if ((currentShields == shieldsHealthMax) && ( (currentHealth + heal) < healthMax ))
    {
        target.SetHealth( (currentHealth + heal) )
    }

    //盾量溢出生命全满 设盾量为最大值
    else if (((currentShields + heal) > shieldsHealthMax) && ( currentHealth == healthMax ))
    {
        target.SetShieldHealth(shieldsHealthMax)
    }

    //盾量不满生命全满 回盾
    else if (((currentShields + heal) < shieldsHealthMax) && ( currentHealth == healthMax ))
    {
        target.SetShieldHealth((currentShields + heal))
    }

    //都不满 先回血
    else if (((currentShields + heal) < shieldsHealthMax) && ( (currentHealth + heal) < healthMax ))
    {
        target.SetHealth( (currentHealth + heal) )
    }
}
#endif
