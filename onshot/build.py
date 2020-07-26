
import subprocess, os, shutil, sys

name = 'onshot'

kwargs = {}
if '--debug' not in sys.argv:
    kwargs[ 'stdout' ] = subprocess.DEVNULL
    kwargs[ 'stderr' ] = subprocess.PIPE

if shutil.which( 'moonc' ) is None:
    print( 'Unable to find `moonc` on path. Is Moonscript properly installed?' )
    exit( 1 )

# used for adding globals like `gui` to the whitelist
# TODO: find a fix for windows
if os.path.exists( 'lint_config.moon' ) and (not os.path.exists( 'lint_config.lua' ) or os.stat( 'lint_config.moon' ).st_mtime > os.stat( 'lint_config.lua' ).st_mtime):
    print( 'Compiling `lint_config.moon`... ', end='', flush=True )
    subprocess.run( [shutil.which( 'moonc' ), os.path.abspath( 'lint_config.moon' )], check = True, **kwargs )
    print( 'DONE.' )

print( 'Checking moonscripts... ', end='', flush=True )
result = subprocess.run( [shutil.which( 'moonc' ), '-l', '.'], **kwargs )
if result.returncode: 
    print( 'FAILED.' )
    if kwargs and result.stderr:
        print( result.stderr.decode() )
else: print( 'OK.' )

print( f'Compiling `{name}.moon`... ', end='', flush=True )
result = subprocess.run( [shutil.which( 'moonc' ), os.path.abspath( f'{name}.moon' )], **kwargs )
if result.returncode: 
    print( 'FAILED.' )
    if kwargs and result.stderr:
        print( result.stderr.decode() )
    exit( 1 )
else: print( 'OK.' )

print( 'Fixing lua...', end='', flush=True )
with open( f'{name}.lua', 'rb' ) as f:
    lua = f.read()
lua = lua.replace( b'return "__REMOVE_ME__"', b'' )
if os.path.exists( f'{name}.xml' ):
    with open( f'{name}.xml', 'rb' ) as f:
        lua = lua.replace( b'"__XML_CODE__"', b'[[' + f.read() + b']]' )
with open( f'{name}.lua', 'wb' ) as f:
    f.write( lua )
print( 'DONE.' )

luanames = [ 'lua5.1', 'lua' ]
for luapath in luanames:
    if shutil.which( luapath ) is not None: break
else:
    print( 'Unable to find lua executable.' )
    exit( 1 )

print( 'Minifying lua...', end='', flush=True )
r = subprocess.run( [luapath, 'minifier.lua', f'{name}.lua', f'{name}_minified.lua'], **kwargs )
if result.returncode: 
    print( 'FAILED.' )
    if kwargs and result.stderr:
        print( result.stderr.decode() )
    exit( 1 )
else:
    print( 'OK.' )

print( f'Shrinked by {1 - (os.stat( f"{name}_minified.lua" ).st_size / os.stat( f"{name}.lua" ).st_size):%} ({os.stat( f"{name}_minified.lua" ).st_size - os.stat( f"{name}.lua" ).st_size} bytes)' )
