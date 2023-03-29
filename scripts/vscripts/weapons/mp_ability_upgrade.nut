global function OnWeaponTossReleaseAnimEvent_ability_upgrade
global function OnWeaponActivate_ability_upgrade
global function OnWeaponDeactivate_ability_upgrade

void function OnWeaponActivate_ability_upgrade( entity weapon )
{
    #if SERVER
    entity weaponOwner = weapon.GetWeaponOwner()
    thread PlayBattleChatterLineDelayedToSpeakerAndTeam( weaponOwner, "bc_super", 0.1 )
    #endif
}

void function OnWeaponDeactivate_ability_upgrade( entity weapon )
{

}

var function OnWeaponTossReleaseAnimEvent_ability_upgrade( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity owner = weapon.GetWeaponOwner()
    int shieldmax = owner.GetShieldHealthMax()
    int shield = owner.GetShieldHealth()

#if SERVER
    if ( shieldmax == 100 ) 
    {
        thread Lv4AndDrop( owner, shieldmax )
    }
    else if ( shieldmax - shield >= 20 ) 
    {
        thread FixAndDrop( owner, shieldmax )
    }
    else if( shieldmax - shield < 20 ) 
    {
        thread CalculateArmorLevelAndUpgrade( owner )
    }
#endif

return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}

void function CalculateArmorLevelAndUpgrade( entity owner )
{
#if SERVER
    int shieldmax = owner.GetShieldHealthMax()
    
	if (shieldmax == 0)
    {
		Inventory_SetPlayerEquipment(owner, "armor_pickup_lv1", "armor")
        thread FixAndDrop2( owner, shieldmax )
    }
	else if (shieldmax == 50)
    {
		Inventory_SetPlayerEquipment(owner, "armor_pickup_lv2", "armor")
        thread FixAndDrop2( owner, shieldmax )
    }
	else if (shieldmax == 75)
    {
		Inventory_SetPlayerEquipment(owner, "armor_pickup_lv3", "armor")
        thread FixAndDrop2( owner, shieldmax )
    }
#endif
}
#if SERVER
entity function PlayerThrowLoot( entity owner, string ref, vector angles = <0, 0, 0>, int count = 1 )
{
	vector origin = GetThrowOrigin( owner )
	vector fwd    = AnglesToForward( owner.EyeAngles() )

	entity loot = SpawnGenericLoot( ref, origin, angles, count )

	SetItemSpawnSource( loot, eSpawnSource.PLAYER_DROP, owner )
	FakePhysicsThrow( owner, loot, fwd * 100 )

	BroadcastItemDrop( owner, ref )

	return loot

}
#endif
void function Lv4AndDrop( entity owner, int shieldmax )
{
    #if SERVER
    Inventory_SetPlayerEquipment(owner, "armor_pickup_lv4_all_fast", "armor")
    wait 0.1
    owner.SetShieldHealth( shieldmax )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    #endif
}
void function FixAndDrop( entity owner, int shieldmax )
{
    #if SERVER
    wait 0.1
    owner.SetShieldHealth( shieldmax )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    #endif
}
void function FixAndDrop2( entity owner, int shieldmax )
{
    #if SERVER
    wait 0.1
    owner.SetShieldHealth( shieldmax )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    wait 0.1
    PlayerThrowLoot( owner, "health_pickup_combo_large", <0, 0, 0>, 1 )
    #endif
}