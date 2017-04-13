function DoomRL.addscore( add_score )
	player.wolf_score = player.wolf_score + add_score
	if player.wolf_score >= player.wolf_score_next and player.wolf_lives < 9 then
		player:play_sound("wolf_oneup.pickup")
		player.wolf_lives = math.min(player.wolf_lives + 1, 9)
		player.wolf_score_next = player.wolf_score_next * 2
	end
end