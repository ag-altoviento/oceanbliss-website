"""Browser test for the gallery's full-screen photo viewer (site/js/gallery.js).

Runs in the Playwright Docker image from scripts/test.sh, against site/ on disk.
"""
import re
import sys

from playwright.sync_api import expect, sync_playwright

PAGE = "file:///site/index.html"


def count_text(page):
    return page.locator(".viewer-count").inner_text()


def run(browser, viewport, has_touch):
    page = browser.new_page(viewport=viewport, has_touch=has_touch)
    errors = []
    page.on("pageerror", lambda e: errors.append(str(e)))
    page.goto(PAGE)

    total = page.locator(".gallery a").count()
    viewer = page.locator("dialog.viewer")
    expect(viewer).not_to_be_visible()

    # Tapping the third photo opens the viewer on that photo, not a new page.
    page.locator(".gallery a").nth(2).click()
    expect(viewer).to_be_visible()
    assert page.url == PAGE, page.url
    expect(page.locator(".viewer-count")).to_have_text(f"3 / {total}")
    third = page.locator(".viewer figure img").nth(2)
    expect(third).to_have_attribute("src", "images/porch-pool-view.jpg")

    # Keyboard and buttons move one photo at a time.
    page.keyboard.press("ArrowRight")
    expect(page.locator(".viewer-count")).to_have_text(f"4 / {total}")
    page.locator(".viewer-prev").click()
    expect(page.locator(".viewer-count")).to_have_text(f"3 / {total}")

    # Quick taps, before the previous animation ends, still move one photo each.
    page.keyboard.press("ArrowRight")
    page.locator(".viewer-prev").click()
    for _ in range(3):
        page.locator(".viewer-next").click()
    for _ in range(3):
        page.locator(".viewer-prev").click()
    expect(page.locator(".viewer-count")).to_have_text(f"3 / {total}")

    # Swiping is native scrolling: once the button's smooth scroll has settled,
    # scroll the track one photo and the counter follows.
    page.wait_for_function(
        "() => { const t = document.querySelector('.viewer-track');"
        " return Math.abs(t.scrollLeft - 2 * t.clientWidth) < 2; }"
    )
    page.locator(".viewer-track").evaluate("t => t.scrollBy({left: t.clientWidth})")
    expect(page.locator(".viewer-count")).to_have_text(f"4 / {total}")

    # The first photo can't go back; the last can't go forward.
    page.locator(".viewer-track").evaluate("t => t.scrollTo({left: 0})")
    expect(page.locator(".viewer-count")).to_have_text(f"1 / {total}")
    expect(page.locator(".viewer-prev")).to_be_disabled()

    # Escape and the close button both close it, and the page can scroll again.
    page.keyboard.press("Escape")
    expect(viewer).not_to_be_visible()
    page.locator(".gallery a").nth(total - 1).click()
    expect(page.locator(".viewer-count")).to_have_text(f"{total} / {total}")
    expect(page.locator(".viewer-next")).to_be_disabled()
    page.locator(".viewer-close").click()
    expect(viewer).not_to_be_visible()
    expect(page.locator("html")).not_to_have_class(re.compile("viewer-open"))

    assert not errors, errors
    page.close()


def main():
    with sync_playwright() as p:
        for name in ("chromium", "webkit"):
            browser = getattr(p, name).launch()
            run(browser, {"width": 1280, "height": 800}, has_touch=False)
            run(browser, {"width": 390, "height": 844}, has_touch=True)
            browser.close()
            print(f"viewer: {name} desktop and phone OK")


if __name__ == "__main__":
    sys.exit(main())
