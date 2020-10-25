#!/usr/bin/env python3
import random
import os
import string


choices = 'QAZWSXEDCRFVTGBYHNUJMIKOLP1234567890'

HOSTNAME = "%s%s%s%s%s%s%s" % (
    random.choice(choices),
    random.choice(choices),
    random.choice(choices),
    random.choice(choices),
    random.choice(choices),
    random.choice(choices),
    random.choice(choices),
    )

os.system(f"sudo hostnamectl set-hostname {HOSTNAME}")
os.system(f"""sudo sh -c 'echo "{HOSTNAME} > /etc/hostname"'""")



print("your new hostname is: " + HOSTNAME)
