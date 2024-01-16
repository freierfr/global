data "cloudflare_zone" "freier_fr" {
  name = "freier.fr"
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.freier_fr.id
  name    = "test"
  value   = "203.0.113.10"
  type    = "A"
  proxied = true
}

locals {
  google_mx = [
    ["alt2.aspmx.l.google.com", 5],
    ["alt1.aspmx.l.google.com", 5],
    ["aspmx.l.google.com", 1],
    ["aspmx2.googlemail.com", 10],
    ["aspmx3.googlemail.com", 10],
    ["aspmx4.googlemail.com", 10],
    ["aspmx5.googlemail.com", 10],
  ]
}

locals {
  stumpy_TXT = [
    ["niels.freier.fr", "v=spf1 ~all"],
    ["freier.fr", "v=spf1 ~all"],
    ["_dmarc", "v=DMARC1;  p=none; rua=mailto:4e54b8f55216439085be374484c57839@dmarc-reports.cloudflare.net"],
    ["freier.fr", "MS=ms30866331"],
  ]
}

resource "cloudflare_record" "freier_TXT_bluesky" {
  count   = length(var.bluesky_users)
  zone_id = data.cloudflare_zone.freier_fr.id
  name    = "_atproto.${var.bluesky_users[count.index][0]}"
  value   = var.bluesky_users[count.index][1]
  type    = "TXT"
}

locals {
  stumpy_CNAME = [
    ["googleed45bd58e1042e7c", "google.com.", 10800, true],
    ["christoph.freier.fr.", "kawameicha.github.io", 10800, false],
    ["niels", "stumpyfr.github.io", 10800, false],
    ["www.niels", "stumpyfr.github.io", 10800, false],
  ]
}

resource "cloudflare_record" "TXT" {
  count   = length(local.stumpy_TXT)
  zone_id = data.cloudflare_zone.freier_fr.id
  name    = local.stumpy_TXT[count.index][0]
  value   = local.stumpy_TXT[count.index][1]
  type    = "TXT"
}

resource "cloudflare_record" "CNAME" {
  count    = length(local.stumpy_CNAME)
  zone_id  = data.cloudflare_zone.freier_fr.id
  name     = local.stumpy_CNAME[count.index][0]
  value    = local.stumpy_CNAME[count.index][1]
  priority = local.stumpy_CNAME[count.index][2]
  proxied  = local.stumpy_CNAME[count.index][3]
  type     = "CNAME"
}


resource "cloudflare_record" "MX" {
  count    = length(local.google_mx)
  zone_id  = data.cloudflare_zone.freier_fr.id
  name     = "freier.fr"
  value    = local.google_mx[count.index][0]
  priority = local.google_mx[count.index][1]
  type     = "MX"
}
