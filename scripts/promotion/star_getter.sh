#!/bin/bash
# Star Getter - Quick promotion actions via CLI
# Usage: ./star_getter.sh [action] [repo]

set -e

USERNAME="bad-antics"
REPOS=(nullsec-linux nullsec-webfuzz blackflag-ecu mysterymachine ai-entropy-mapper nullsec-beacon)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║          ⭐ NULLSEC STAR GETTER ⭐               ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Track stars across all repos
track_stars() {
    echo -e "${BLUE}📊 Tracking stars...${NC}\n"
    
    total_stars=0
    for repo in "${REPOS[@]}"; do
        stats=$(gh api "repos/${USERNAME}/${repo}" --jq '{s: .stargazers_count, f: .forks_count, w: .watchers_count}' 2>/dev/null || echo '{"s":0,"f":0,"w":0}')
        stars=$(echo "$stats" | jq -r '.s')
        forks=$(echo "$stats" | jq -r '.f')
        watchers=$(echo "$stats" | jq -r '.w')
        
        total_stars=$((total_stars + stars))
        
        # Progress bar (target: 50 stars)
        progress=$((stars * 20 / 50))
        if [ $progress -gt 20 ]; then progress=20; fi
        bar=$(printf '█%.0s' $(seq 1 $progress))
        empty=$(printf '░%.0s' $(seq 1 $((20 - progress))))
        
        printf "%-25s [%s%s] %3d/50 ⭐ | 🍴%d\n" "$repo" "$bar" "$empty" "$stars" "$forks"
    done
    
    echo ""
    echo -e "${GREEN}Total stars: ${total_stars}${NC}"
}

# Generate shareable links
generate_links() {
    echo -e "${BLUE}🔗 Shareable Links${NC}\n"
    
    for repo in "${REPOS[@]}"; do
        url="https://github.com/${USERNAME}/${repo}"
        echo -e "${YELLOW}${repo}${NC}"
        echo "  GitHub:  $url"
        echo "  Star:    $url/stargazers"
        echo "  Reddit:  https://www.reddit.com/submit?url=$url&title=Check+out+${repo}"
        echo "  Twitter: https://twitter.com/intent/tweet?text=Check+out+${repo}+${url}"
        echo "  HN:      https://news.ycombinator.com/submitlink?u=$url&t=${repo}"
        echo ""
    done
}

# Create promotional content
create_content() {
    repo=${1:-nullsec-linux}
    url="https://github.com/${USERNAME}/${repo}"
    
    echo -e "${BLUE}📝 Promotional Content for ${repo}${NC}\n"
    
    echo -e "${YELLOW}=== Reddit Title ===${NC}"
    echo "${repo} - Open source security toolkit for penetration testing"
    echo ""
    
    echo -e "${YELLOW}=== Reddit Post ===${NC}"
    cat << EOF
Hey r/netsec,

I've been working on **${repo}**, an open-source security project:

🔗 **GitHub:** ${url}

**Features:**
- [Feature 1]
- [Feature 2]
- [Feature 3]

Would love feedback from the community! Star if you find it useful ⭐

EOF
    
    echo -e "${YELLOW}=== Tweet ===${NC}"
    echo "🔒 Just released ${repo} - open source security toolkit for penetration testing and security research. Check it out! ${url} #infosec #cybersecurity #pentesting #opensource"
    echo ""
    
    echo -e "${YELLOW}=== LinkedIn Post ===${NC}"
    cat << EOF
🚀 Excited to share my latest open-source project: ${repo}

This tool helps security professionals with [brief description].

Key features:
✅ Feature 1
✅ Feature 2
✅ Feature 3

Check it out on GitHub: ${url}

#CyberSecurity #OpenSource #InfoSec #PenetrationTesting

EOF
}

# Open links in browser
open_socials() {
    repo=${1:-nullsec-linux}
    url="https://github.com/${USERNAME}/${repo}"
    
    echo -e "${BLUE}🌐 Opening social links for ${repo}...${NC}"
    
    # Reddit submit
    xdg-open "https://www.reddit.com/submit?url=${url}&title=${repo}+-+Open+Source+Security+Toolkit" 2>/dev/null &
    sleep 1
    
    # Twitter
    xdg-open "https://twitter.com/intent/tweet?text=Check+out+${repo}+-+open+source+security+toolkit+${url}+%23infosec+%23cybersecurity" 2>/dev/null &
    sleep 1
    
    # HN
    xdg-open "https://news.ycombinator.com/submitlink?u=${url}&t=${repo}" 2>/dev/null &
    
    echo -e "${GREEN}✅ Opened Reddit, Twitter, and HN submit pages${NC}"
}

# Check API setup status
check_setup() {
    echo -e "${BLUE}🔧 Checking setup...${NC}\n"
    
    # GitHub CLI
    if command -v gh &> /dev/null; then
        echo -e "${GREEN}✅ GitHub CLI installed${NC}"
        if gh auth status &> /dev/null; then
            echo -e "${GREEN}✅ GitHub authenticated${NC}"
        else
            echo -e "${RED}❌ GitHub not authenticated - run: gh auth login${NC}"
        fi
    else
        echo -e "${RED}❌ GitHub CLI not installed${NC}"
    fi
    
    # Python
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✅ Python3 installed${NC}"
    else
        echo -e "${RED}❌ Python3 not installed${NC}"
    fi
    
    # praw
    if python3 -c "import praw" 2>/dev/null; then
        echo -e "${GREEN}✅ praw (Reddit) installed${NC}"
    else
        echo -e "${YELLOW}⚠️  praw not installed - run: pip install praw${NC}"
    fi
    
    # tweepy
    if python3 -c "import tweepy" 2>/dev/null; then
        echo -e "${GREEN}✅ tweepy (Twitter) installed${NC}"
    else
        echo -e "${YELLOW}⚠️  tweepy not installed - run: pip install tweepy${NC}"
    fi
    
    # Config
    config_path="$(dirname "$0")/config.yaml"
    if [ -f "$config_path" ]; then
        echo -e "${GREEN}✅ config.yaml exists${NC}"
    else
        echo -e "${RED}❌ config.yaml missing${NC}"
    fi
}

# Watch stars in real-time
watch_stars() {
    echo -e "${BLUE}👀 Watching stars (Ctrl+C to stop)...${NC}\n"
    
    while true; do
        clear
        print_header
        track_stars
        echo ""
        echo -e "${YELLOW}Refreshing in 60 seconds...${NC}"
        sleep 60
    done
}

# Bulk update repo metadata
update_repos() {
    echo -e "${BLUE}📝 Updating repo metadata...${NC}\n"
    
    for repo in "${REPOS[@]}"; do
        echo -e "${YELLOW}Updating ${repo}...${NC}"
        
        # Add common topics
        gh repo edit "${USERNAME}/${repo}" \
            --add-topic security \
            --add-topic pentesting \
            --add-topic cybersecurity \
            --add-topic hacking \
            --add-topic opensource 2>/dev/null || true
        
        echo -e "${GREEN}✅ ${repo} updated${NC}"
    done
}

# Main
print_header

case "${1:-help}" in
    track)
        track_stars
        ;;
    links)
        generate_links
        ;;
    content)
        create_content "$2"
        ;;
    open)
        open_socials "$2"
        ;;
    check)
        check_setup
        ;;
    watch)
        watch_stars
        ;;
    update)
        update_repos
        ;;
    help|*)
        echo "Usage: $0 [command] [repo]"
        echo ""
        echo "Commands:"
        echo "  track    - Show star progress for all repos"
        echo "  links    - Generate shareable links for all repos"
        echo "  content  - Generate promotional content for a repo"
        echo "  open     - Open social media submit pages in browser"
        echo "  check    - Check if all tools are set up"
        echo "  watch    - Watch star counts in real-time"
        echo "  update   - Update repo topics/metadata"
        echo ""
        echo "Examples:"
        echo "  $0 track"
        echo "  $0 content nullsec-webfuzz"
        echo "  $0 open nullsec-linux"
        ;;
esac
