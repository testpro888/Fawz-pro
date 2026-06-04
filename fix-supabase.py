#!/usr/bin/env python3
import os, re

# Files that have the duplicate 'const supabase' issue - only active files
files_to_fix = [
    'sales.html',
    'history-order.html', 
    'log-commission.html',
    'obligasi-ipo.html',
    'reksadana-data.html',
    'reksadana-order.html',
    'revenue-data.html',
    'sales-commission.html',
    'sales-tracker.html',
    'waran-terstruktur.html',
]

for fname in files_to_fix:
    if not os.path.exists(fname):
        print(f'SKIP (not found): {fname}')
        continue
    
    with open(fname, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Check if it has the pattern
    if 'const supabase = window.supabase.createClient' not in content:
        print(f'SKIP (no pattern): {fname}')
        continue
    
    # Replace const supabase with window._supabaseClient
    # Step 1: rename declaration
    content = content.replace(
        'const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);',
        'if (!window._supabaseClient) { window._supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY); }\n    const supabase = window._supabaseClient;'
    )
    
    with open(fname, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f'FIXED: {fname}')

print('\nDone!')
