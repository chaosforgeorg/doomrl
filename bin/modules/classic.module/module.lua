module = {
    id = "classic",
    name = "Classic Mode",
    author = "Kornel Kisielewicz",
    webpage = "http://chaosforge.org/",
    version = {0,3,0},
    drlver = {0,9,9,7},
    type = "episode",
    description = "Classic approach to DoomRL - 10 levels ending with Cyberdemon, no special levels, no klasses or master traits. At the same time an example of a episodic mod. Includes a badge series.",
    klass = 4,
    challenge = true,
    difficulty = true,
    gsupport = true,
    award = {
        name = "Classicist",
        levels = {
            { name = "Bronze",   desc = "Complete on ITYTD" },
            { name = "Silver",   desc = "Complete on HMP" },
            { name = "Gold",     desc = "Complete on UV" },
            { name = "Platinum", desc = "Complete on UV/100%" },
            { name = "Diamond",  desc = "Complete on N!/90%" },
            { name = "Angelic",  desc = "Complete on N! w/o damage" },
        }
    }
}