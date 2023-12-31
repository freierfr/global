data "cloudflare_zone" "mensier_fr" {
  name = "mensier.fr"
}


locals {
  mensier_google_mx = [
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
  mensier_TXT = [
    ["mensier.fr", "v=spf1 ~all"],
    ["mensier.fr", "google-site-verification=DtTuQEFu86eQNF-wIvGbnGn8Xj0Dpnns_aXvkbB4aHo"],
    ["_dmarc", "v=DMARC1; p=none; rua=mailto:c19178e85cb04bbca11af1a86736134b@dmarc-reports.cloudflare.net"]
  ]
}


resource "cloudflare_record" "mensier_TXT" {
  count   = length(local.mensier_TXT)
  zone_id = data.cloudflare_zone.mensier_fr.id
  name    = local.mensier_TXT[count.index][0]
  value   = local.mensier_TXT[count.index][1]
  type    = "TXT"
}


resource "cloudflare_record" "mensier_MX" {
  count    = length(local.mensier_google_mx)
  zone_id  = data.cloudflare_zone.mensier_fr.id
  name     = "mensier.fr"
  value    = local.mensier_google_mx[count.index][0]
  priority = local.mensier_google_mx[count.index][1]
  type     = "MX"
}
