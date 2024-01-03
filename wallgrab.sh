# Function to prompt user for input and handle skipping
prompt_input() {
    read -p "$1 (Press Enter to skip): " input
    if [[ -z "$input" ]]; then
        echo "skip"
    else
        echo "$input"
    fi
}

# Function to download wallpapers
download_wallpapers() {
    local response="$1"
    # local threshold="$2"

    THRESHOLD=$(prompt_input "Enter the number of wallpapers you want to download")
    if [[ "$THRESHOLD" == "skip" ]]; then
        THRESHOLD=0
    fi

    local counter=0

    echo "$response" | jq -c '.data[]' | while read -r row; do
        IMAGE_URL=$(echo "$row" | jq -r '.path')
        if [[ ! -z "$IMAGE_URL" ]]; then
            ((counter++))
            mkdir -p ~/wallpapers
            wget -q --show-progress -P ~/wallpapers "$IMAGE_URL"
            if [[ $counter -eq $THRESHOLD ]]; then
                break  
            fi
        fi
    done
}

# Prompt user for inputs
QUERY=$(prompt_input "Enter query (tagname / -tagname / +tag1 +tag2 / etc.)")
CATEGORIES=$(prompt_input "Enter categories (100/101/111/etc. - 1 for on, 0 for off)")
PURITY=$(prompt_input "Enter purity (100/110/111/etc. - 1 for on, 0 for off)")
SORTING=$(prompt_input "Enter sorting (date_added/relevance/random/views/favorites/toplist)")
ORDER=$(prompt_input "Enter order (desc/asc)")
TOPRANGE=$(prompt_input "Enter topRange (1d/3d/1w/1M/3M/6M/1y)")
ATLEAST=$(prompt_input "Enter atleast resolution (e.g., 1920x1080)")
RESOLUTIONS=$(prompt_input "Enter resolutions (comma-separated e.g., 1920x1080,1920x1200)")
RATIOS=$(prompt_input "Enter ratios (e.g., 16x9,16x10)")
COLORS=$(prompt_input "Enter colors (e.g., 660000,990000,cc0000,...)")
PAGE=$(prompt_input "Enter page (e.g., 1)")
SEED=$(prompt_input "Enter seed (optional)")

# Prompt user for threshold
# THRESHOLD=$(prompt_input "Enter the number of wallpapers you want to download")
# if [[ "$THRESHOLD" == "skip" ]]; then
#     THRESHOLD=0
# fi

# Base API endpoint
BASE_URL="https://wallhaven.cc/api/v1/search"
URL="$BASE_URL"

# Constructing the API endpoint based on parameters
if [[ "$QUERY" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL?q=$QUERY"
    else
        URL="$URL&q=$QUERY"
    fi
fi

if [[ "$CATEGORIES" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL?categories=$CATEGORIES"
    else
        URL="$URL&categories=$CATEGORIES"
    fi
fi

if [[ "$PURITY" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL?purity=$PURITY"
    else
        URL="$URL&purity=$PURITY"
    fi
fi

if [[ "$SORTING" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL?sorting=$SORTING"
    else
        URL="$URL&sorting=$SORTING"
    fi
fi

if [[ "$ORDER" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&order=$ORDER"
    else
        URL="$URL&order=$ORDER"
    fi
fi

if [[ "$TOPRANGE" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&topRange=$TOPRANGE"
    else
        URL="$URL&topRange=$TOPRANGE"
    fi
fi

if [[ "$ATLEAST" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&atleast=$ATLEAST"
    else
        URL="$URL&atleast=$ATLEAST"
    fi
fi

if [[ "$RESOLUTIONS" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&resolutions=$RESOLUTIONS"
    else
        URL="$URL&resolutions=$RESOLUTIONS"
    fi
fi

if [[ "$RATIOS" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&ratios=$RATIOS"
    else
        URL="$URL&ratios=$RATIOS"
    fi
fi

if [[ "$COLORS" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&colors=$COLORS"
    else
        URL="$URL&colors=$COLORS"
    fi
fi

if [[ "$PAGE" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&page=$PAGE"
    else
        URL="$URL&page=$PAGE"
    fi
fi

if [[ "$SEED" != "skip" ]]; then
    if [[ "$URL" == *'search' ]]; then
        URL="$URL&seed=$SEED"
    else
        URL="$URL&seed=$SEED"
    fi
fi

# Debug: Print the constructed URL
echo "Constructed URL: $URL"

# Send request and save the response
RESPONSE=$(curl -s "$URL")

# Check if the response is valid
if [[ $? -ne 0 ]]; then
    echo "Failed to fetch data from the API."
    exit 1
fi

# Check if the 'data' field exists in the JSON response
if ! echo "$RESPONSE" | jq -e '.data' > /dev/null; then
    echo "No 'data' field found in the API response."
    exit 1
fi

# Download wallpapers
download_wallpapers "$RESPONSE" "$PAGE"

echo "Images downloaded successfully to ~/wallpapers"
