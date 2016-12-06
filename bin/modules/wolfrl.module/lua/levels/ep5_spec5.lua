--[[ The casino (drawing influence from Casablanca, but only for nominal
     atmosphere) is the last level before the boss, and the idea here is pretty
     simple: don't have enough equipment to take on the boss?  Pawn some stuff
     you don't need, gamble at the casino, then hope you win enough to trade up
     for what you do.  Of course like all casinos the odds aren't in your favor.

     Well, in theory you could abuse the RNG, but if you're willing to go through
     THAT much trouble you deserve the damn prizes.  Combat on the other hand
     is not allowed; no robbing the casino (unless someone can think of a really
     clever way to pull it off that can be integrated into the level).
--]]

register_level "spec5" {
	name  = "The Casino",
	entry = "On level @1 he entered the casino.",
	welcome = "Of all the gin joints in all the world...",
	level = 9,

	canGenerate = function ()
		return CHALLENGE == "challenge_ep5"
	end,

	OnCompletedCheck = function ()
		return level.status >= 4
	end,

	OnRegister = function ()
		register_medal "casino1" {
			name  = "Roulette Ball",
			desc  = "Awarded for beating the casino.",
			hidden  = true,
		}
		register_medal "casino2" {
			name  = "Weighted Roulette Ball",
			desc  = "Awarded for breaking the bank.",
			hidden  = true,
		}

		--Todo: replace LEVERS with OnAct CELLS.
		register_item "lever_casino_1" {
			name   = "slot machine",
			ascii  = "ù",
			--asciilow   = '.',
			color  = LIGHTGRAY,
			sprite = SPRITE_FLOOR,
			sprite = SPRITE_FLOOR,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "dangerous",
			desc = "play slots",

			color_id = false,

			OnUse = function(self,being)
				local function getScore( reels )
					for _,payout in ipairs(level.data.slots.payouts) do
						if ((reels[1] == payout[1] or payout[1] == 0) and (reels[2] == payout[2] or payout[2] == 0) and (reels[3] == payout[3] or payout[3] == 0)) then return payout[4] end
					end

					return 0
				end
				local function getReelDesc( reels )
					local reel_desc = ""
					for i,reel in ipairs(reels) do
						if (i ~= 1) then reel_desc = reel_desc .. " " end
						reel_desc = reel_desc .. level.data.slots.symbols[reel]
					end

					return reel_desc
				end

				local function playGame()
					ui.msg_clear()
					ui.msg("The wheels turn...")
					local spin_result = {}
					for i=1,3 do spin_result[i] = table.random_pick( level.data.slots.reels[i] ) end

					local score = getScore(spin_result)
					ui.msg(getReelDesc(spin_result).. (score > 0 and "!" or "."))
					return score
				end
				local function getBet(options, max_bet)
					if (max_bet <= 0) then return -1 end

					local index = 0
					local question = "Bet: "
					local answer = "\001"
					for _,amt in ipairs(options) do
						index = index + 1
						answer = answer .. index
						if (index > 1) then question = question .. ", " end
						if (amt > max_bet) then
							question = question .. "@<(" .. index  .. ")@>=" .. max_bet
							break
						else
							question = question .. "@<(" .. index  .. ")@>=" .. amt
						end
					end

					ui.msg_clear()
					local result = ui.msg_choice( question, answer )
					if result == "\001" then return 0 end

					local ret = options[tonumber(result)]
					if ret > max_bet then ret = max_bet end
					return ret
				end


				local bet = getBet(level.data.slots.bets, level.data.player)
				if (bet < 0) then
					ui.msg("You are out of chips.")
				elseif (bet > 0) then
					local result = playGame()
					if (result > 0) then
						level.data.player = level.data.player + (result * bet)
						level.data.won = level.data.won + (result * bet)
						level.data.bank = level.data.bank - (result * bet)
						ui.msg("You win x" .. result .. " (" .. level.data.player .. ")")
					else
						level.data.player = level.data.player - bet
						level.data.lost = level.data.lost + bet
						level.data.bank = level.data.bank + bet
					end
				end

				return false
			end,
		}
		register_item "lever_casino_2" {
			name   = "blackjack table",
			ascii  = "ù",
			--asciilow   = '.',
			color  = LIGHTGRAY,
			sprite = SPRITE_FLOOR,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "dangerous",
			desc = "play blackjack",

			color_id = false,

			OnUse = function(self,being)
				local function getScore( hand )
					local has_ace = false
					local score = 0
					for _,card in ipairs(hand) do
						local card_value = ((card-1) % 13)+1
						if (card_value == 1) then has_ace = true
						elseif (card_value > 10) then card_value = 10 end

						score = score + card_value
					end

					if (has_ace and score + 10 <= 21) then score = score + 10 end
					return score
				end
				local function getHandDesc( is_dealer, hand )
					local hand_desc = ""
					for i,card in ipairs(hand) do
						local card_value
						if (i == 1 and is_dealer) then card_value = "?"
						else card_value = level.data.blackjack.values[((card-1) % 13)+1] end

						if (i ~= 1) then hand_desc = hand_desc .. " " end
						hand_desc = hand_desc .. card_value
					end

					return hand_desc
				end
				local function getCard()
					local card = level.data.blackjack.deck[level.data.blackjack.position]
					level.data.blackjack.position = level.data.blackjack.position + 1
					return card
				end
				local function shuffleDeck()
					if (level.data.blackjack.position > 26) then
						level.data.blackjack.deck = table.shuffle( level.data.blackjack.deck )
						level.data.blackjack.position = 1
					end
				end

				local function doesPlayerHit( hand )
					local hand_score = getScore(hand)
					if (hand_score >= 21) then return false end

					return ui.msg_confirm("Hit?")
				end
				local function doesDealerHit( hand )
					local hand_score = getScore(hand)
					if (hand_score < 17) then return true else return false end
				end

				local function playGame()
					local player_hand = {}
					local dealer_hand = {}

					ui.msg_clear()
					ui.msg("The dealer starts.")
					table.insert(player_hand, getCard())
					table.insert(dealer_hand, getCard())
					table.insert(player_hand, getCard())
					table.insert(dealer_hand, getCard())

					ui.msg("You: " .. getHandDesc( false, player_hand ))
					ui.msg("Him: " .. getHandDesc( true,  dealer_hand ))
					while (doesPlayerHit( player_hand )) do
						table.insert(player_hand, getCard())
						ui.msg(getHandDesc( false, player_hand ) .. "...")

						if (getScore( player_hand ) > 21) then return -1 end
					end
					while (doesDealerHit( dealer_hand )) do
						ui.msg("hit...")
						table.insert(dealer_hand, getCard())

						if (getScore( dealer_hand ) > 21) then
							ui.msg(getHandDesc( false, dealer_hand ) .. "!")
							return 1
						end
					end
					ui.msg(getHandDesc( false, dealer_hand ) .. "...")

					return (getScore( player_hand ) - getScore( dealer_hand ))
				end
				local function getBet(options, max_bet)
					if (max_bet <= 0) then return -1 end

					local index = 0
					local question = "Bet: "
					local answer = "\001"
					for _,amt in ipairs(options) do
						index = index + 1
						answer = answer .. index
						if (index > 1) then question = question .. ", " end
						if (amt > max_bet) then
							question = question .. "@<(" .. index  .. ")@>=" .. max_bet
							break
						else
							question = question .. "@<(" .. index  .. ")@>=" .. amt
						end
					end

					ui.msg_clear()
					local result = ui.msg_choice( question, answer )
					if result == "\001" then return 0 end

					local ret = options[tonumber(result)]
					if ret > max_bet then ret = max_bet end
					return ret
				end


				local bet = getBet(level.data.blackjack.bets, level.data.player)
				if (bet < 0) then
					ui.msg("You are out of chips.")
				elseif (bet > 0) then
					local result = playGame()
					if (result < 0) then
						ui.msg("You lose.")
						level.data.player = level.data.player - bet
						level.data.lost = level.data.lost + bet
						level.data.bank = level.data.bank + bet
					elseif (result == 0) then ui.msg("Push.")
					else
						level.data.player = level.data.player + bet
						level.data.won = level.data.won + bet
						level.data.bank = level.data.bank - bet
						ui.msg("You win! (" .. level.data.player .. ")")
					end
					shuffleDeck()
				end

				return false
			end,
		}
		register_item "lever_casino_3" {
			name   = "roulette table",
			ascii  = "ù",
			--asciilow   = '.',
			color  = LIGHTGRAY,
			sprite = SPRITE_FLOOR,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "dangerous",
			desc = "play roulette",

			color_id = false,

			OnUse = function(self,being)
				return false
			end,
		}
		register_item "lever_casino_4" {
			name   = "clerk",
			ascii  = "ù",
			--asciilow   = '.',
			color  = LIGHTGRAY,
			sprite = SPRITE_FLOOR,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "beneficial",
			desc = "exchange chips",

			color_id = false,

			OnUse = function(self,being)
				local function valueItem(item)
					local item_proto = items[item.id]
					if (not item_proto or item.itype == ITEMTYPE_LEVER) then return -1 end
					if (((item.itype == ITEMTYPE_ARMOR or item.itype == ITEMTYPE_BOOTS)    and item.durability < item.maxdurability)
					 or ((item.itype == ITEMTYPE_AMMO  or item.itype == ITEMTYPE_AMMOPACK) and item.ammo < item.ammomax)) then return 0 end

					return math.max( math.ceil(math.pow(item_proto.level,0.95) / (math.log10(item_proto.weight))), 1) * 10
				end
				local function pawnItem(sell_item)
					local value = valueItem(sell_item)
					if (value < 0) then return false end
					if (value == 0) then
						ui.msg("We're not interested in your " .. sell_item.name .. ".")
						return false
					end
					if (ui.msg_confirm("" .. value .. " chips for your " .. sell_item.name .. "?" )) then
						level.data.player = level.data.player + value
						level.data.sold = level.data.sold + value

						ui.msg_clear()
						ui.msg("Sold! (" .. level.data.player .. ")")
						sell_item:destroy()
						return true
					end

					return false
				end
				local function pawnItems()
					--Check all of our drop squares
					for _,drop_area in ipairs(level.data.tradezones) do
						for drop_coord in drop_area:coords() do
							local sell_item = level:get_item(drop_coord)
							if (sell_item and pawnItem(sell_item)) then return true end
						end
					end

					return false
				end

				local function buyItemMessages()
					local ret = {}

					for i,set in ipairs(level.data.items) do
						local count = 0
						local str = "Buy "
						local ans = ""

						for _,avail in ipairs(set) do
							if (avail[3] <= level.data.player and avail[4] ~= 0) then
								count = count + 1
								str = str .. "@<(" .. avail[1] .. ")@> " .. items[avail[2]].name .. " "
								ans = ans .. avail[1]
							end
						end
						if (count > 0) then
							str = str .. "@<n@>ext"
							ans = ans .. "n\001"
							table.insert(ret, i, { str, ans })
						else
							table.insert(ret, i, {} )
						end
					end

					return ret
				end
				local function buyItems()
					local messages = buyItemMessages()
					local count = 0

					for i,msg in ipairs(messages) do
						repeat --Gratuitous hack added so that I can break and continue the loop
							if #msg == 0 then break end

							count = count + 1
							ui.msg_clear()
							local result = ui.msg_choice( msg[1], msg[2] )
							if result == "n" then break end
							if result == "\001" then return end

							--They chose something, create it already.
							local choice = nil
							for _,obj in ipairs(level.data.items[i]) do
								if (obj[1] == result) then
									choice = obj
									break
								end
							end
							if choice then
								local price = choice[3]
								level.data.player = level.data.player - price
								level.data.bought = level.data.bought + price
								choice[4] = math.max(choice[4]-1, -1)

								ui.msg_clear()
								ui.msg("Your item is outside.")
								level:drop_item( choice[2], generator.random_empty_coord{ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }, false )
							end

							return
						until true
					end

					--If there were no available items print something helpful
					if (count == 0) then
						ui.msg("Need chips? Pawn some items by dropping them near the register.")
					end
				end

				if (not pawnItems()) then
					buyItems()
				end

				return false
			end,
		}
	end,

	Create = function ()
		level.name = "Aces High"
		--level.name = "Ace Of Spades"
		generator.fill( "void", area.FULL )

		--Generate the level data
		level.data.hostile = 0
		level.data.bank = 50000
		level.data.player = 0
		level.data.bought = 0
		level.data.sold = 0
		level.data.won = 0
		level.data.lost = 0
		level.data.items = { { { "1", "wolf_smed",      100, -1 },
		                       { "2", "wolf_lmed",      500,  2 },
		                       { "3", "wolf_armor2",    250, -1 },
		                       { "4", "wolf_armor3",    750,  1 },
		                     },{
		                       { "1", "wolf_mod_power",   1000, 2 },
		                       { "2", "wolf_mod_tech",    1000, 2 },
		                       { "3", "wolf_mod_agility", 1000, 2 },
		                       { "4", "wolf_mod_bulk",    1000, 2 },
		                     },{
		                       { "1", "wolf_kurz",      500, -1 },
		                       { "2", "wolf_semi1",    1000,  1 },
		                       { "3", "wolf_auto1",    1500,  1 },
		                       { "4", "wolf_assault1", 2500,  1 },
		                     },{
		                       { "1", "wolf_ushieldc", 3000,  1 },
		                       { "2", "wolf_umirec",   4000,  1 },
		                       { "3", "wolf_upowerc",  5000,  1 },
		                   } }

		level.data.outerdoor = coord.new(18,9)
		level.data.innerdoor = coord.new(21,9)
		level.data.outerdoorzone = area.new( 19, 9, 19, 9 )
		level.data.innerdoorzone = area.new( 20, 9, 20, 9 )
		level.data.approachzone = area.new( 15, 5, 17, 9 )
		level.data.dmzzone = area.new( 19, 9, 20, 9 )
		level.data.floorzone = area.new( 18, 1, 78, 19 )
		level.data.tradezones = { area.new( 16, 6, 17, 7 ),
		                          area.new( 66, 3, 67, 4 ),
		                        }
		level.data.roulettezone = area.new( 58, 9, 72, 14 )

		--Slots are simple, though I couldn't find much in the way of historical data
		--on them.  Someone familiar with 1940s era slots would really help!
		--Slot design apparently encourages mid-level payout.  Virtual stops probably
		--didn't exist in 1940 which saves on the math at least, or would if there
		--was a graphical component, but there isn't...
		--For designing my payouts I relied largely on this page: http://wizardofodds.com/games/slots/appendix/4/
		level.data.slots = {}
		level.data.slots.bets = { 5,
		                          10,
		                          25,
		                          50,
		                          100,
		                        }
		level.data.slots.symbols = { [0]="any", "cherry", "orange", "bell", "7", "plum", "lemon", "bar" }
		level.data.slots.reels = { { 1,1,1,1,1, 2,2,2,2, 3,3,3, 4, 5,5,5, 6,6,6, 7, },
		                           { 1,1, 2,2,2,2, 3,3,3,3, 4, 5,5,5, 6,6,6,6,6, 7, },
		                           { 1,1,1, 2,2,2,2, 3,3,3,3, 4, 5, 6,6,6,6,6,6, 7, },
		                         }
		level.data.slots.payouts = { { 4,4,4, 500 },
		                             { 7,7,7, 100 },
		                             { 5,5,5,  50 },
		                             { 3,3,3,  20 },
		                             { 2,2,2,  15 },
		                             { 1,1,1,  10 },
		                             { 1,1,0,   5 },
		                             { 1,0,0,   2 },
		                           }

		--Blackjack is fairly straightforward; the deck gets shuffled halfway through hands
		level.data.blackjack = {}
		level.data.blackjack.bets = { 10,
		                              25,
		                              50,
		                              100,
		                              500,
		                            }
		level.data.blackjack.suit = { "spades", "clubs", "diamonds", "hearts" }
		level.data.blackjack.values = { "ace", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king" }
		level.data.blackjack.position = 1
		level.data.blackjack.deck = { }
		for i=1,52 do level.data.blackjack.deck[i] = i end
		level.data.blackjack.deck = table.shuffle( level.data.blackjack.deck )

		--Roulette is a computationally heavy game.  In the casino it's more of a set piece.
		level.data.roulette = {}
		level.data.roulette.bets = { 10,
		                             50,
		                             100,
		                             500,
		                             1000,
		                           }
		level.data.roulette.state = "bets" --"bets, spin, closed, done
		level.data.roulette.curtime = 30
		level.data.roulette.time = { bets = 50, spin = 30, closed = 40, done = 60 }
		level.data.roulette.colormap = { [0]=0, 1,2,1,2,1,2,1,2,1,2, 2,1,2,1,2,1,2,1, 1,2,1,2,1,2,1,2,1,2, 2,1,2,1,2,1,2,1, }
		level.data.roulette.result = 0
		level.data.text = { eng = { results = { [0]="zero", "one", "two",  "three", "four",   "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty", "twenty-one",  "twenty-two", "twenty-three", "twenty-four",  "twenty-five", "twenty-six", "twenty-seven", "twenty-eight", "twenty-nine", "thirty", "thirty-one",   "thirty-two",  "thirty-three", "thirty-four",   "thirty-five", "thirty-six", },
		                            colors  = { "red", "black", },
		                            divide  = { "odd", "even", },
		                            weight  = { "low", "high", },
		                            betting = { "Ladies and Gentlemen", "Please place your bets", "Betting is closed", "The winner is", },
		                          },
		                    fre = { results = { [0]="zéro", "un",  "deux", "trois", "quatre", "cinq", "six", "sept",  "huit",  "neuf", "dix", "onze",   "douze",  "treize",   "quatorze", "quinze",  "seize",   "dix-sept",  "dix-huit", "dix-neuf", "vingt",  "vingt et un", "vingt-deux", "vingt-trois",  "vingt-quatre", "vingt-cinq",  "vingt-six",  "vingt-sept",   "vingt-huit",   "vingt-neuf",  "trente", "trente et un", "trente-deux", "trente-trois", "trente-quatre", "trente-cinq", "trente-six", },
		                            colors  = { "rouge", "noir", },
		                            divide  = { "impair", "pair", },
		                            weight  = { "manque", "passe", },
		                            betting = { "Mesdames et Messieurs", "Faites vos jeux s'il vous plaît", "Rien ne va plus", "Le numéro gagnant", },
		                          } ,
		                  }


		local basetranslation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_brwall", flags = { LFPERMANENT } },
			['O'] = "floor",
			[">"] = "stairs",

			["+"] = "floor",
			["="] = "floor",
			["-"] = "floor",

			['S'] = "wolf_cywall",
			['s'] = "floor",
			['B'] = "wolf_grwall",
			['b'] = "floor",
			['R'] = "wolf_rewall",
			['r'] = "floor",
			['c'] = "floor",

			["1"] = "floor",
			["2"] = "floor",
			["3"] = "floor",
			["4"] = "floor",
			["5"] = "floor",
			["6"] = "floor",
			["7"] = "floor",
			["8"] = "floor",
			["9"] = "floor",
		}
		local gametranslation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_brwall", flags = { LFPERMANENT } },
			['O'] = { "pillar", flags = { LFPERMANENT } },
			[">"] = "stairs",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['S'] = "wolf_cywall",
			['s'] = { "floor", item = "lever_casino_1" },
			['B'] = "wolf_grwall",
			['b'] = { "floor", item = "lever_casino_2" },
			['R'] = "wolf_rewall",
			['r'] = { "floor", item = "lever_casino_3" },
			['c'] = { "floor", item = "lever_casino_4" },

			["1"] = { "floor", being = "wolf_soldier1" }, --guest
			["2"] = { "floor", being = "wolf_soldier2" }, --guest
			["3"] = { "floor", being = "wolf_soldier3" }, --guest
			["4"] = { "floor", being = "wolf_guard2" },   --crew
			["5"] = { "floor", being = "wolf_ss1" },      --dealer
			["6"] = { "floor", being = "wolf_ss2" },      --croupier
			["7"] = { "floor", being = "wolf_officer1" }, --pit boss
			["8"] = { "floor", being = "wolf_super" },    --bouncer
			["9"] = { "floor", being = "wolf_assault2" }, --security
		}

		--prototype: barred entry, stairs down to the pit, cafe, head to the pit.
		local map = [[
...............#`````````````````````````````````````````````````````````
...............#``````````````################`````````````##########````
...............#``````````````#.SSS.SSSS.SSS.#````````######....cO.4#````
...............#``````````````#..s...ss...s..##########.........8-..#````
...............###````````````#1..............5...............#######````
...............O.##``###################.....BBB..............#``````````
..............cO.4#``#1.......3.......2#8.....b.......#########``````````
...............#OO####..#..#..#..#..#..#...........bB5#``````````````````
..>............-..=..#.................#7...........B2#``````#########```
...............####..#..##.........##..+......b.......########.rRRR6.#```
...............#``#..#..##.........##..#.....BBB................r....#```
...............#``#..#.................+......5................r.....#```
...............#``#....................####################...rRRR6.3#```
...............#``#...................8#``````````````````############```
...............#``######################`````````````````````````````````
...............#`````````````````````````````````````````````````````````
...............#`````````````````````````````````````````````````````````
...............#`````````````````````````````````````````````````````````
...............#`````````````````````````````````````````````````````````
...............#`````````````````````````````````````````````````````````
]]
		generator.place_tile( basetranslation, map, 3, 1)
		generator.place_tile( gametranslation, map, 3, 1)
		level.light[ level.data.floorzone ][ LFNOSPAWN ] = true

		level:player(5, 10)
	end,

	OnEnter = function ()
		level.status = 0

		--They may be our enemies elsewhere but here the guards behave.
		for b in level:beings() do
			if (b.id == "wolf_soldier1" or b.id == "wolf_soldier2" or b.id == "wolf_soldier3") then
				b.inv:clear()
				b.eq:clear()
				b:add_property( "ai_type_attacked", "flee_ranged_ai" )
				--How to hook the OnAttacked though?
				b.ai_type = "passive_ai"
			elseif (b.id == "wolf_guard2") then
				b.inv:clear()
				b.eq:clear()
				b.flags[ BF_HUNTING ] = true
				b:add_property( "ai_type_attacked", "flee_ranged_ai" )
				b.ai_type = "passive_ai"
			elseif (b.id == "wolf_ss1" or b.id == "wolf_ss2") then
				b.inv:clear()
				b.eq:clear()
				b.flags[ BF_SESSILE ] = true
				b:add_property( "ai_type_attacked", "flee_ranged_ai" )
				b.ai_type = "passive_ai"
			elseif (b.id == "wolf_super") then
				b.inv:clear()
				b.eq:clear()
				b.flags[ BF_SESSILE ] = true
				b:add_property( "ai_type_attacked", "melee_seek_ai" )
				b.ai_type = "passive_ai"
			elseif (b.id == "wolf_officer1" or b.id == "wolf_assault2") then
				b:add_property( "ai_type_attacked", "former_ai" )
				b.ai_type = "passive_ai"
			end
		end
	end,

	OnTick = function ()
		local function IsPlayerUnarmed()
			if (player.eq.weapon ~= nil or player.eq.prepared ~= nil) then return false end
			for item in player.inv:items() do
				if (item and (item.itype == ITEMTYPE_RANGED or item.itype == ITEMTYPE_NRANGED or item.itype == ITEMTYPE_MELEE)) then
					return false
				end
			end

			return true
		end
		local function CheckApproach()
			if (level.status == 0 and level.data.approachzone:contains(player.position)) then
				level.status = 1
				if (IsPlayerUnarmed()) then
					ui.msg("Welcome. Come in and relax and don't cause trouble.")
				else
					ui.msg("Welcome. Drop the weapons and you can come in.")
				end
			end
		end
		local function CheckItemDrop()
			--Sneaky players might try to drop items through walls.  This checks for that (really sneaky players can probably get around this if they have enough items).
			for dmz_coord in level.data.dmzzone:coords() do
				local dmz_item = level:get_item(dmz_coord)
				if (dmz_item ~= nil) then
					ui.msg(table.random_pick( {"Can't have that.", "Whoops.", "I'll just throw this out.", "How'd that get here.",} ))

					local new_coord = generator.random_empty_coord{ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
					if (new_coord) then
						dmz_item:displace(new_coord)
					else --Filled up everything?  Penalty, no item you jerk.
						dmz_item:destroy()
					end
				end
			end
		end
		local function CheckOpenOuterDoor()
			if ((level.map[ level.data.outerdoor ] == "lmdoor2" and level.data.approachzone:contains(player.position) and IsPlayerUnarmed())
			 or (level.map[ level.data.outerdoor ] == "lmdoor2" and level.data.outerdoorzone:contains(player.position))) then
				if (level.status < 2) then
					player:msg("The door opens.")
					level.status = 2
				end
				player:play_sound("door.open")
				level.map[ level.data.outerdoor ] = "omdoor2"
			end
		end
		local function CheckOpenInnerDoor()
			if (level.map[ level.data.innerdoor ] == "lmdoor1" and level.data.innerdoorzone:contains(player.position) and IsPlayerUnarmed()) then
				if (level.status < 3) then
					player:msg("The door opens.")
					level.status = 3
				end
				player:play_sound("door.open")
				level.map[ level.data.innerdoor ] = "omdoor1"
			end
		end
		local function CheckCloseOuterDoor()
			if ((level.map[ level.data.outerdoor ] == "omdoor2" and level.data.innerdoorzone:contains(player.position))
			 or (level.map[ level.data.outerdoor ] == "omdoor2" and level.data.approachzone:contains(player.position) and not IsPlayerUnarmed())) then
				local door_item = level:get_item(level.data.outerdoor)
				if (door_item ~= nil) then
					--Nice try.  I will now spite you.
					ui.msg("*crunch*")
					door_item:destroy()
				end
				player:play_sound("door.close")
				level.map[ level.data.outerdoor ] = "lmdoor2"
			end
		end
		local function CheckCloseInnerDoor()
			if (level.map[ level.data.innerdoor ] == "omdoor1" and level.data.outerdoorzone:contains(player.position)) then
				local door_item = level:get_item(level.data.innerdoor)
				if (door_item ~= nil) then
					ui.msg("*crunch*")
					door_item:destroy()
				end
				player:play_sound("door.close")
				level.map[ level.data.innerdoor ] = "lmdoor1"
			end
		end

		CheckApproach()
		CheckItemDrop()
		CheckOpenOuterDoor()
		CheckOpenInnerDoor()
		CheckCloseOuterDoor()
		CheckCloseInnerDoor()

--		level.data.roulettezone  = area.new( 58, 9, 72, 14 )

		--Roulette is constantly running but we don't bother to check it
		--unless the player is 'in range'.
		
		
		
	end,

	OnKill = function ()
		level.data.hostile = 2
	end,

	OnExit = function (being)
		--Print something based on how much trouble the player caused
		--How can I remove the not-dead casino patrons from the kill counter?
	end,
}
