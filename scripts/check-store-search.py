#!/usr/bin/env python3
"""Diagnostic Apple search-API evidence; never a native App Store rank claim."""
import argparse
import datetime
import json
import urllib.parse
import urllib.request

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--country', required=True, help='Two-letter storefront code')
parser.add_argument('--term', default='eidome')
args = parser.parse_args()
if len(args.country) != 2 or not args.country.isascii() or not args.country.isalpha():
    parser.error('country must be a two-letter storefront code')
report = {'checked_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
          'country': args.country.lower(), 'term': args.term,
          'source': 'Apple public search API, not native App Store search', 'app_id': 6811835765}
failed = False
for endpoint, params in [('lookup', {'id': 6811835765}),
                         ('search', {'term': args.term, 'entity': 'software', 'limit': 200})]:
    params['country'] = args.country.lower()
    url = 'https://itunes.apple.com/' + endpoint + '?' + urllib.parse.urlencode(params)
    try:
        with urllib.request.urlopen(url, timeout=25) as response:
            data = json.load(response)
        results = data['results']
        if not isinstance(results, list):
            raise ValueError('Invalid results payload')
        matches = [(i + 1, item) for i, item in enumerate(results)
                   if item.get('trackId') == 6811835765]
        report[endpoint] = {'url': url, 'returned_count': len(results),
                            'matches': [{'api_position': i, 'name': r.get('trackName'),
                                         'version': r.get('version'),
                                         'public_url': r.get('trackViewUrl')} for i, r in matches]}
    except (OSError, ValueError, KeyError, TypeError) as error:
        failed = True
        report[endpoint] = {'url': url, 'error': str(error), 'status': 'unavailable'}
print(json.dumps(report, indent=2))
raise SystemExit(1 if failed else 0)
