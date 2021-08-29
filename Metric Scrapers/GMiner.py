from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException

def configure_driver():
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    driver = webdriver.Chrome(options = chrome_options)
    return driver

def get_metrics(driver):
    driver.get(f"http://<IP_ADDRESS:API_PORT>)
    try:
        WebDriverWait(driver, 5).until(lambda s: s.find_element_by_id("miner_stat").is_displayed())
    except TimeoutException:
        print("TimeoutException: Element not found")
        return None

    soup = BeautifulSoup(driver.page_source, "html.parser")
    algo = soup.find(text="Algorithm").findNext('td').contents[0]
    hashrate = soup.find(text="Pool Hashrate").findNext('td').contents[0]
    uptime = soup.find(text="Uptime").findNext('td').contents[0]
    print(algo,hashrate,uptime)

driver = configure_driver()
get_metrics(driver)
driver.close()
