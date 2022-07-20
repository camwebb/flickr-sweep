function requestCmd(tail,           request)
{
  uniq();
  request = "https://www.flickr.com/services/rest/                \
             ?oauth_nonce=" UNIQ "                                \
             &oauth_timestamp=" TIME "                            \
             &oauth_consumer_key=" API_KEY "                      \
             &oauth_signature_method=HMAC-SHA1                    \
             &oauth_version=1.0                                   \
             &oauth_token=" USER_TOKEN "                          \
             &" tail ;
  gsub(/\s/,"", request);

  request = request "&oauth_signature=" sign("GET", request, USER_SECRET "&");
  return "curl -s \"" request "\"";
}

function sign(method, url, key,       message, parts, param, nparam, i, sig, cmd)
{
  message = toupper(method) ;
  # get url and encode it
  split(url, parts, "?");
  message = message "&" urlencode(parts[1]) "&";
  # sort parameters and encode and concatenate them
  nparam = split(parts[2], param, "&");
  asort(param);
  for (i = 1; i < nparam; i++) {
    message = message urlencode(param[i]) "%26";
  }
  message = message urlencode(param[nparam]);
  
  # create openssl command (use explicit /bin/echo, in case using tcsh)
  cmd = "/bin/echo -n \"" message "\" | openssl dgst -sha1 -binary -hmac \"" key "\" | base64";
  RS = "\n" ;
  cmd | getline sig;
  close(cmd);
  return urlencode(sig);
}

function urlencode(text,      hextab, i, ord, encoded, c, lo, hi)
{
  # urlencode, by Heiner Steven (heiner.steven@odn.de)

  split ("1 2 3 4 5 6 7 8 9 A B C D E F", hextab, " ")
  hextab[0] = 0
  for ( i=1; i<=255; ++i ) ord[ sprintf ("%c", i) "" ] = i + 0

  encoded = ""
  for ( i=1; i<=length(text); ++i ) {
    c = substr (text, i, 1)
    if ( c ~ /[a-zA-Z0-9.\-_]/ ) {
      encoded = encoded c             # safe character ADDED `_'
    } else if ( c == " " ) {
      encoded = encoded "+"   # special handling
    } else {
      # unsafe character, encode it as a two-digit hex-number
      lo = ord [c] % 16
      hi = int (ord [c] / 16);
      encoded = encoded "%" hextab[hi] hextab[lo]
    }
  }
  return encoded;
}

function uniq()
{
  TIME = strftime("%s");
  UNIQ = TIME "-" sprintf("%.3d", int(rand() * 1000)); 
}
