extends Node

signal rewarded_ad_completed(reward_type: String)
signal rewarded_ad_failed

func show_rewarded_ad(reward_type: String = "bonus_moves") -> void:
	# Placeholder for AdMob / Unity Ads SDK integration
	# Simulates successful rewarded video view
	print("AdManager: Rewarded Ad displayed for ", reward_type)
	await get_tree().create_timer(1.0).timeout
	rewarded_ad_completed.emit(reward_type)
	
	if reward_type == "bonus_moves":
		GameManager.add_bonus_moves(3)

func show_interstitial_ad() -> void:
	print("AdManager: Interstitial Ad displayed")
