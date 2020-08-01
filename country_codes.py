from sys import argv

countries = {
    "albania": "al",
    "austrailia": "au",
    "austria": "at",
    "belguim": "be",
    "brazil": "br",
    "bulgaria": "bg",
    "canada": "ca",
    "czech Republic": "cz",
    "denmark": "dk",
    "finland": "fi",
    "france": "fr",
    "germany": "de",
    "greece": "gr",
    "hong kong": "hk",
    "hungary": "hu",
    "ireland": "ie",
    "israel": "il",
    "italy": "it",
    "japan": "jp",
    "latvia": "lv",
    "luxembourg": "lu",
    "moldova": "md",
    "netherlands": "nl",
    "new Zeland": "nz",
    "norway": "no",
    "poland": "pl",
    "romania": "ro",
    "serbia": "rs",
    "singapore": "sg",
    "spain": "es",
    "sweden": "se",
    "switzerland": "ch",
    "uk": "gb",
    "united arab emirates": "ae",
    "usa": "us",
}

# be sure to quote your arg so countries with spaces don't break the script
if len(argv) != 2:
    exit(1)
else:
    pass

country = argv[1].lower()

if country in countries:
    print(countries[country])
else:
    print("Not in country dict.")
    exit(1)
