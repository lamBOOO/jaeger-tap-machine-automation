import REPL
using REPL.TerminalMenus
using WebDriver
using YAML

function enter_shop!(s, cfg)
  navigate!(s, "https://shop.jaegermeister.de")

  dd_field = Element(s, "xpath", """//*[@id="agegate-dd"]""")
  mm_field = Element(s, "xpath", """//*[@id="agegate-mm"]""")
  yyyy_field = Element(s, "xpath", """//*[@id="agegate-yyyy"]""")

  element_keys!(dd_field, lpad(cfg["birth_dd"],2,"0"))
  element_keys!(mm_field, lpad(cfg["birth_mm"],2,"0"))
  element_keys!(yyyy_field, string(cfg["birth_yyyy"]))

  cookie_button = Element(s, "xpath", """//*[@id="cookie-permission--accept-button"]""")
  click!(cookie_button)
end

function register_all!(s, cfg)
  emails = [string(cfg["gmail_id"], "+$(lpad(i,3,"0"))@gmail.com") for i=cfg["gmail_start"]:cfg["gmail_end"]]
  logout!(s)
  for email in emails
    navigate!(s, "https://shop.jaegermeister.de/mein-konto")

    mr_radio = Element(s, "xpath", """//html/body/div[2]/div/section/div/div/div[1]/form/div[1]/div[2]/div[1]/label[1]/span[1]""")
    click!(mr_radio)

    firstname_field = Element(s, "xpath", """//*[@id="firstname"]""")
    element_keys!(firstname_field, cfg["firstname"])
    lastname_field = Element(s, "xpath", """//*[@id="lastname"]""")
    element_keys!(lastname_field, cfg["lastname"])

    mm_option = Element(s, "xpath", string("""/html/body/div[2]/div/section/div/div/div[1]/form/div[1]/div[2]/div[4]/div[1]/select/option[""", cfg["birth_dd"]+1, "]"))
    click!(mm_option)
    mm_option = Element(s, "xpath", string("""/html/body/div[2]/div/section/div/div/div[1]/form/div[1]/div[2]/div[4]/div[2]/select/option[""", cfg["birth_mm"]+1, "]"))
    click!(mm_option)
    yyyy_option = Element(s, "xpath", string("""/html/body/div[2]/div/section/div/div/div[1]/form/div[1]/div[2]/div[4]/div[3]/select/option[""", abs(cfg["birth_yyyy"]-2004)+1, "]"))
    click!(yyyy_option)

    email_field = Element(s, "xpath", """//*[@id="register_personal_email"]""")
    element_keys!(email_field, email)
    pw_field = Element(s, "xpath", """//*[@id="register_personal_password"]""")
    element_keys!(pw_field, cfg["pw"])

    street_field = Element(s, "xpath", """//*[@id="street"]""")
    element_keys!(street_field, cfg["street"])
    zipcode_field = Element(s, "xpath", """//*[@id="zipcode"]""")
    element_keys!(zipcode_field, cfg["zipcode"])
    city_field = Element(s, "xpath", """//*[@id="city"]""")
    element_keys!(city_field, cfg["city"])

    tos_button = Element(s, "xpath", """/html/body/div[2]/div/section/div/div/div[1]/form/div[5]/div/label/span[1]""")
    click!(tos_button)

    sleep(2)

    # submit_button = Element(s, "xpath", """/html/body/div[2]/div/section/div/div/div[1]/form/div[7]/button""")
    submit_button = Element(s, "xpath", """//*[@id="jae-registration-form"]/div[7]/div/button""")
    click!(submit_button)

    sleep(3)
    logout!(s)

    println("Done:", email)
  end
end

function login!(s, email, pw)
  navigate!(s, "https://shop.jaegermeister.de/mein-konto")
  email_box = Element(s, "xpath", """//*[@id="email"]""")
  pw_box = Element(s, "xpath", """//*[@id="passwort"]""")
  login_button = Element(s, "xpath", """/html/body/div[2]/div/section/div/div/div[2]/div[2]/div/div/form/div[5]/button""")

  # fill credentials
  element_keys!(email_box, email)
  element_keys!(pw_box, pw)

  # click login btn
  click!(login_button)
end

function logout!(s)
  navigate!(s, "https://shop.jaegermeister.de/mein-konto/abmelden")
end

function apply!(s)
  navigate!(s, "https://shop.jaegermeister.de/shotmachine")
  apply_button = Element(s, "xpath", """/html/body/div[2]/div/section/div/div/div[1]/div[1]/div[3]/div[3]/button""")
  click!(apply_button)
end

function apply_all!(s, cfg)
  emails = [string(cfg["gmail_id"], "+$(lpad(i,3,"0"))@gmail.com") for i=cfg["gmail_start"]:cfg["gmail_end"]]
  logout!(s)
  for email in emails
    login!(s, email, cfg["pw"])
    apply!(s)
    sleep(1)
    logout!(s)
    println("Done:", email)
  end
end

function automate_apply(s, cfg)
  while true
    apply_all!(s, cfg)
    for i=60:1
      println("sleep $(i) mins")
      sleep(60)
    end
  end
end





println("""
 ╦┌─┐┌─┐┌─┐┌─┐┬─┐  ╔╦╗┌─┐┌─┐  ╔╦╗┌─┐┌─┐┬ ┬┬┌┐┌┌─┐  ╦  ┌─┐┌┬┐┌┬┐┌─┐┬─┐┬ ┬
 ║├─┤├┤ │ ┬├┤ ├┬┘   ║ ├─┤├─┘  ║║║├─┤│  ├─┤││││├┤   ║  │ │ │  │ ├┤ ├┬┘└┬┘
╚╝┴ ┴└─┘└─┘└─┘┴└─   ╩ ┴ ┴┴    ╩ ╩┴ ┴└─┘┴ ┴┴┘└┘└─┘  ╩═╝└─┘ ┴  ┴ └─┘┴└─ ┴
""")

rwd = RemoteWebDriver(Capabilities("chrome"), host = "127.0.0.1", port = 4444)
s = Session(rwd)
cfg = YAML.load_file("config.yml")
enter_shop!(s)

options = [
  "Create accounts"
  "Apply in all accounts"
]
menu = RadioMenu(options, pagesize=4)
choice = request("Choose your favorite fruit:", menu)
if choice == 1
  register_all!(s, cfg)
elseif choice == 2
  automate_apply!(s, cfg)
else
  println("Menu canceled.")
end