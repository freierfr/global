data "cloudflare_zone" "akhmadova_fr" {
  name = "akhmadova.fr"
}


locals {
  akhmadova_google_mx = [
    ["aspmx.l.google.com", 1],
    ["alt2.aspmx.l.google.com", 5],
    ["alt1.aspmx.l.google.com", 5],
    ["aspmx2.googlemail.com", 10],
    ["aspmx3.googlemail.com", 10],
    ["aspmx4.googlemail.com", 10],
    ["aspmx5.googlemail.com", 10],
  ]
}

locals {
  akhmadova_TXT = [
    ["akhmadova.fr", "v=spf1 ~all"],
    ["akhmadova.fr", "google-site-verification=Jdn75h5Y7Ca24__vH6a03eeheeHKKIsbnsHlfnaTsiE"],
    ["_dmarc", "v=DMARC1; p=none; rua=mailto:5b734b2579934a38b93a3adf9f7129e5@dmarc-reports.cloudflare.net"]
  ]
}


resource "cloudflare_record" "akhmadova_TXT" {
  count   = length(local.akhmadova_TXT)
  zone_id = data.cloudflare_zone.akhmadova_fr.id
  name    = local.akhmadova_TXT[count.index][0]
  value   = local.akhmadova_TXT[count.index][1]
  type    = "TXT"
}


resource "cloudflare_record" "akhmadova_MX" {
  count    = length(local.akhmadova_google_mx)
  zone_id  = data.cloudflare_zone.akhmadova_fr.id
  name     = "akhmadova.fr"
  value    = local.akhmadova_google_mx[count.index][0]
  priority = local.akhmadova_google_mx[count.index][1]
  type     = "MX"
}
