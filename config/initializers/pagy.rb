# Pagy configuration
# See https://ddnexus.github.io/pagy/

Pagy::DEFAULT[:limit] = 50

# Handle overflow (page number exceeds last page)
# Returns empty page instead of raising Pagy::OverflowError
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :empty_page
