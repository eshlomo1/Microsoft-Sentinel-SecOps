break

# AD DB Partitions

# DistinguishedName components
#  CN, OU, DC





# A "type accelerator" is a short name for a longer .NET type.
[System.DirectoryServices.DirectorySearcher] | gm -s
[ADSISearcher] | gm -s

# The problem is that we have to know the object's distinguished name path
# in order to touch it with [ADSI].  We can find objects using the searcher.
$searcher = [ADSISEARCHER][ADSI]""
# Notice the searcher properties include Filter, SearchRoot, & SearchScope.
# Notice the searcher methods include FindOne & FindAll.
$searcher | gm
# The default filter is "(objectClass=*)".
$searcher | fl *

# We really don't want to return all objects in the domain, so we specify
# a standard LDAP filter for the objects we want.
$searcher.Filter = "(cn=administrator)"
$admin = $searcher.FindOne()
$admin | fl *

# We can reference the Path and Properites this way.
$admin.Path
$admin.Properties
$admin.Properties.Item("name")
$admin.Properties.Item("description")

# We can use wildcards to find multiple accounts with the FindAll() method.
$searcher.Filter = "(cn=a*)"
$a = $searcher.FindAll()
$a | ft Path

# We use the SearchScope property to define how deep to look.
# Let's pass a bad value to see what the error tells us are valid values.
$searcher.SearchScope = "foo"
# Notice the error output...
#   The possible enumeration values are "Base, OneLevel, Subtree".
# These values are well-documented on MSDN.  For now we usually
# specify "Subtree" to get all items under the search path.
$searcher.SearchScope = "Subtree"

# We use the SearchRoot property to define where to look.
# The default is the root of the current domain.
# Let's look at the configuration partition instead.
# Note we cannot pass a simple string.  The value must be a directory entry.
# And don't forget to preface the path with "LDAP://".
$searcher.SearchRoot = [ADSI]"LDAP://cn=configuration,dc=cohovineyard,dc=com"
# It would be better not to hard code the path, so let's pull it from RootDSE.
$searcher.SearchRoot = [ADSI]"LDAP://$(([ADSI]"LDAP://RootDSE").configurationNamingContext)"

    # For future reference RootDSE has several handy properties.
    [ADSI]"LDAP://RootDSE" | fl *

# Now let's look for all AD sites there.
$searcher.Filter = "(objectClass=site)"
$searcher.FindAll()

# To work with the output we must capture it into a variable.
$sites = $searcher.FindAll()
$sites
$sites | gm
$sites | ft Path
$sites | ForEach-Object {$_.Properties.Item("name")}
