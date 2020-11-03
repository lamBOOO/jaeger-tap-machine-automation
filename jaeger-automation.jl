import REPL
using REPL.TerminalMenus
using Dates
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
  emails = [string(cfg["gmail_id"], "+A$(lpad(i,3,"0"))@gmail.com") for i=cfg["gmail_start"]:cfg["gmail_end"]]
  logout!(s)
  for email in emails
    navigate!(s, "https://shop.jaegermeister.de/mein-konto")

    mr_radio = Element(s, "xpath", """//*[@id="jae-registration-form"]/div[1]/div[2]/div[1]/label[1]""")
    click!(mr_radio)

    firstname_field = Element(s, "xpath", """//*[@id="firstname"]""")
    element_keys!(firstname_field, cfg["firstname"])
    lastname_field = Element(s, "xpath", """//*[@id="lastname"]""")
    element_keys!(lastname_field, cfg["lastname"])



    mm_menu_button = Element(s, "xpath", string("""//*[@id="jae-registration-form"]/div[1]/div[2]/div[4]/div[1]/span/span[1]/span/span[2]"""))
    click!(mm_menu_button)
    mm_option = Element(s, "xpath", string("""/html/body/span/span/span[2]/ul/li[""", cfg["birth_dd"], "]"))
    click!(mm_option)

    mm_menu_button = Element(s, "xpath", string("""//*[@id="jae-registration-form"]/div[1]/div[2]/div[4]/div[2]/span/span[1]/span/span[2]"""))
    click!(mm_menu_button)
    mm_option = Element(s, "xpath", string("""/html/body/span/span/span[2]/ul/li[""", cfg["birth_mm"], "]"))
    click!(mm_option)

    yy_menu_button = Element(s, "xpath", string("""//*[@id="jae-registration-form"]/div[1]/div[2]/div[4]/div[3]/span/span[1]/span/span[2]"""))
    click!(yy_menu_button)
    yyyy_option = Element(s, "xpath", string("""/html/body/span/span/span[2]/ul/li[""", abs(cfg["birth_yyyy"]-2003)+1, "]"))
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

    tos_button = Element(s, "xpath", """//*[@id="jae-registration-form"]/div[5]""")
    click!(tos_button)

    sleep(2)

    submit_button = Element(s, "xpath", """//*[@id="jae-registration-form"]/div[7]/button""")
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
  login_button = Element(s, "xpath", """//*[@id="jae-login-form"]/div[5]/button""")

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
  println("APPLY START")
  sleep(2)
  navigate!(s, "https://shop.jaegermeister.de/shotmachine")
  sleep(2)
  try
    apply_button = Element(s, "xpath", """/html/body/div[2]/div/section/div/div/div[1]/div[1]/div[3]/div[3]/button""")
    click!(apply_button)
    @info "Applied"
  catch e
    @info "Skipped"
  end
  println("APPLY END")
end

function apply_all!(s, cfg)
  emails = [string(cfg["gmail_id"], "+A$(lpad(i,3,"0"))@gmail.com") for i=cfg["gmail_start"]:cfg["gmail_end"]]
  logout!(s)
  for email in emails
    login!(s, email, cfg["pw"])
    apply!(s)
    sleep(cfg["apply_wait"])
    logout!(s)
    println("Done:", email)
  end
end

"""
Application once per 60 minutes is possible.
"""
function automate_apply!(s, cfg)
  while true
    start_time = now()
    apply_all!(s, cfg)
    waitminutes = round(now() - start_time, Dates.Minute(1)).value
    for i=60-waitminutes:-1:1
      println("sleep $(i) mins")
      navigate!(s, "about:blank") # to not close session, bug?
      sleep(60)
    end
  end
end





println("""
 ╦┌─┐┌─┐┌─┐┌─┐┬─┐  ╔╦╗┌─┐┌─┐  ╔╦╗┌─┐┌─┐┬ ┬┬┌┐┌┌─┐  ╦  ┌─┐┌┬┐┌┬┐┌─┐┬─┐┬ ┬
 ║├─┤├┤ │ ┬├┤ ├┬┘   ║ ├─┤├─┘  ║║║├─┤│  ├─┤││││├┤   ║  │ │ │  │ ├┤ ├┬┘└┬┘
╚╝┴ ┴└─┘└─┘└─┘┴└─   ╩ ┴ ┴┴    ╩ ╩┴ ┴└─┘┴ ┴┴┘└┘└─┘  ╩═╝└─┘ ┴  ┴ └─┘┴└─ ┴
""")

@info "Webdriver: Start"
rwd = RemoteWebDriver(Capabilities("chrome"), host = "127.0.0.1", port = 4444)
# rwd = RemoteWebDriver(Capabilities("firefox"), host = "127.0.0.1", port = 4445)
sleep(1)
s = Session(rwd)
cfg = YAML.load_file("config.yml")
enter_shop!(s, cfg)
@info "Webdriver: End"

options = [
  "Create accounts"
  "Apply in all accounts"
]
menu = RadioMenu(options, pagesize=4)
choice = request("Choose program to run:", menu)
if choice == 1
  register_all!(s, cfg)
elseif choice == 2
  automate_apply!(s, cfg)
else
  println("Menu canceled.")
end
