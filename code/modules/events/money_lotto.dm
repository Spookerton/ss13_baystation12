/datum/event/money_lotto
	var/winner_name = "John Smith"
	var/winner_sum = 0
	var/deposit_success = FALSE
	var/lotto_name = "Solar Slam"


/datum/event/money_lotto/start()
	winner_sum = pick(5000, 10000, 50000, 100000, 500000, 1000000, 1500000)
	if (prob(15))
		if (length(all_money_accounts))
			var/datum/money_account/account = pick(all_money_accounts)
			winner_name = account.owner_name
			deposit_success = account.deposit(winner_sum, "[lotto_name] Lotto winner!", lotto_name)
	else
		winner_name = random_name(pick(MALE, FEMALE), species = SPECIES_HUMAN)
		deposit_success = pick(FALSE, TRUE)


/datum/event/money_lotto/announce()
	var/datum/event/mundane_news/mundane_news = /datum/event/mundane_news
	var/channel = initial(mundane_news.channel)
	var/list/body = list(
		"[channel] congratulates <b>[winner_name]</b> on winning ",
		"[winner_sum][GLOB.using_map.local_currency_name_short] in the [lotto_name] Lotto!",
		"<br>Their money is being"
	)
	if (deposit_success)
		body += " deposited into their account."
	else
		body += list(
			"held over",
			pick(list(
				" invalid account details",
				" an issue with bank routing",
				" security concerns"
			)),
			" and must be claimed in-person at an Interstellar Mail branch."
		)
	body = jointext(body, "")
	for (var/datum/news_network/network as anything in GLOB.news_networks)
		network.CreateArticle(channel, channel, body)
