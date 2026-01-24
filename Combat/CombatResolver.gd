extends Resource

func resolve_combat(attacker: UnitData, defender: UnitData) -> bool:
	print("ID: ", defender.get_id(), " getting attacked")
	
	# Simple math: Damage = Attack Power * Morale
	var damage_to_defender = attacker.attack_power * attacker.morale
	
	defender.take_damage(damage_to_defender)
	
	print("Defender: ", defender.unit_name, " HP: ", defender.get_manpower())

	# Check for deaths
	if defender.get_manpower() <= 0:
		return true # Defender died
	return false # Defender survived
