global function OnWeaponPrimaryAttack_weapon_shield_heal_hopup
global int shieldsHeal
global bool gettingShields
global int currentShields
global int overflow
global int shieldHealthMax


var function OnWeaponPrimaryAttack_weapon_shield_heal_hopup( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )
    if (weapon.HasMod("shield_heal"))
    {
        // printt( "hasmod")
        entity weaponOwner = weapon.GetWeaponOwner()
         shieldsHeal = (weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value )/10)
         currentShields  = weaponOwner.GetShieldHealth()
         shieldHealthMax = weaponOwner.GetShieldHealthMax()
    if ( currentShields < shieldHealthMax )
    {
        gettingShields = true
        // printt( "gettingShields = true")
    }

#if SERVER
    if (gettingShields)
    {
        if (currentShields != shieldHealthMax)
        {
            if ((currentShields + shieldsHeal) > shieldHealthMax)
            {
            thread HealthOwnerOverflow( weapon, weaponOwner )
            // printt( "thread HealOwnerOverflow")
            }
            else 
            thread HealthOwner( weapon, weaponOwner, currentShields, shieldsHeal )
            // printt( "thread HealOwner")
        }
    }
#endif
    }
}

#if SERVER
void function HealthOwner(entity weapon, entity weaponOwner, int currentShields, int shieldsHeal )
{
    currentShields  = weaponOwner.GetShieldHealth()
    shieldsHeal = (weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value )/10)
    weaponOwner.SetShieldHealth( currentShields + shieldsHeal )
    // printt( "HealOwner")
}

void function HealthOwnerOverflow(entity weapon, entity weaponOwner)
{
    shieldHealthMax = weaponOwner.GetShieldHealthMax()
    weaponOwner.SetShieldHealth( shieldHealthMax )
    // printt( "HealOwnerOverflow")
}
#endif