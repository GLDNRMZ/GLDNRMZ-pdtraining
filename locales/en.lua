local Translations = {
    error = {
        ["canceled"]                    = "Canceled",
        ["someone_recently_did_this"]   = "Someone recently did this, try again later..",
        ["cannot_do_this_right_now"]    = "Need 2 police to start...",
        ["you_failed"]                  = "You failed!",
        ["you_cannot_do_this"]          = "You cannot do this..",
        ["you_dont_have_enough_money"]  = "You Dont Have Enough Money",
    },
    success = {
        ["case_has_been_unlocked"]              = "Security case has been unlocked",
        ["you_removed_first_security_case"]     = "You removed the the first layer of security on the case",
        ["you_got_paid"]                        = "You got paid",
        ["send_email_right_now"]                 = "I will send you an e-mail right now!",
    },
    info = {
        ["talking_to_boss"]             = "Getting GPS info..",
        ["unlocking_case"]              = "Unlocking case..",
        ["checking_quality"]            = "Checking Quality",
    },
    mailstart = {
        ["sender"]                      = "Hector",
        ["subject"]                     = "Vehicle Location",
        ["message"]                     = "Updated your gps with the location to a vehicle I got a tip about that contains a briefcase. Retrieve whats inside and follow the directions sent to your email.",
    },
    mail = {
        ["sender"]                      = "Hector",
        ["subject"]                     = "Goods Collection",
        ["message"]                     = "Looks like you got the goods. The case should unlock automatically 5 minutes after you unlocked the first layer of security on it. Bring the goods to the drop off point on your GPS",
    },
    police = {
        ["message"]                     = 'Gang Activity',
        ["code"]                        = '10-18',
        ["bliptitle"]                   = 'Gang Activity',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
