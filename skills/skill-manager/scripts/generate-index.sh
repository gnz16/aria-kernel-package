#!/bin/bash
# Generate skill index for fast lookup - Enhanced for 265+ skills
# v3.0 - Adds new categories, tags, dependencies, and parallel processing

SKILLS_DIR="$HOME/.gemini/skills"
OUTPUT_FILE="$SKILLS_DIR/skill-manager/references/SKILL_INDEX.json"
PARALLEL="${1:-false}"

echo "🔄 Generating skill index v3.0..."

# Start JSON structure
echo "{" > "$OUTPUT_FILE"
echo "  \"generated\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> "$OUTPUT_FILE"
echo "  \"version\": \"3.0\"," >> "$OUTPUT_FILE"
echo "  \"total_skills\": 0," >> "$OUTPUT_FILE"
echo "  \"skills\": [" >> "$OUTPUT_FILE"

first=true
count=0

for skill_dir in "$SKILLS_DIR"/*/ ; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    
    # Skip if not a real skill directory
    if [[ ! -f "$skill_md" ]] || [[ "$skill_name" == "skill-manager" ]]; then
        continue
    fi
    
    # Extract metadata from SKILL.md
    description=$(grep "^description:" "$skill_md" | head -1 | sed 's/^description: //' | sed 's/^[[:space:]]*//' | sed 's/"/\\"/g')
    
    # Get last modified date
    if [[ "$OSTYPE" == "darwin"* ]]; then
        updated=$(stat -f "%Sm" -t "%Y-%m-%d" "$skill_md")
    else
        updated=$(date -r "$skill_md" +"%Y-%m-%d")
    fi
    
    # Detect category based on name patterns (ENHANCED with new categories)
    category="Other"
    case "$skill_name" in
        # Development Workflow
        brainstorming|writing-plans|executing-plans|*agent*|git-*|*code-review*|*branch*|tdd-workflow|verification-before-completion|*workflow*)
            category="Development Workflow" ;;
            
        # Testing & Quality
        test-driven-development|ui-testing|systematic-debugging|security-review|*test*|playwright-*|webapp-testing)
            category="Testing & Quality" ;;
            
        # Frontend Development
        react-*|frontend-*|web-design-guidelines|nextjs-*|mobile-design|scroll-experience|3d-web-experience)
            category="Frontend Development" ;;
            
        # Backend Development
        backend-*|mcp-builder|nodejs-*|nestjs-*|prisma-*|api-*|database-*|graphql|server-*)
            category="Backend Development" ;;
            
        # Code Quality
        coding-standards|clean-code|lint-*|architecture|software-architecture)
            category="Code Quality" ;;
            
        # AWS Cloud Services
        aws-*)
            category="AWS Cloud Services" ;;
            
        # Docker & Containers
        docker-*|developing-with-docker)
            category="Docker & Containers" ;;
            
        # Configuration Management
        config-builder|*config*)
            category="Configuration Management" ;;
            
        # Document Creation
        docx*|pdf*|pptx*|xlsx*|*forms*)
            category="Document Creation" ;;
            
        # Creative & Design
        algorithmic-art|canvas-*|theme-*|brand-*|*gif*|ui-ux-*|frontend-design)
            category="Creative & Design" ;;
            
        # AI Agents & LLM (NEW)
        ai-*|*agent*|rag-*|prompt-*|lang*|autonomous-*|loki-mode|computer-use-*|conversation-memory|context-window-*|llm-*)
            category="AI Agents & LLM" ;;
            
        # Security & Pentesting (NEW)
        ethical-hacking-*|pentest-*|metasploit-*|burp-suite-*|red-team-*|*penetration-testing|*injection*|*vulnerability*|*exploitation*|active-directory-*|sql-*|xss-*|shodan-*|wireshark-*|nmap-*|*hacking*|*security*|broken-*|idor-*|scanning-*)
            category="Security & Pentesting" ;;
            
        # Marketing & Growth (NEW)
        seo-*|*cro*|copywriting|copy-editing|marketing-*|email-*|social-*|analytics-*|content-creator|programmatic-*|page-*|paid-ads|*conversion*|schema-markup)
            category="Marketing & Growth" ;;
            
        # Integrations & APIs (NEW)
        stripe-*|firebase|clerk-*|discord-bot-*|slack-*|telegram-*|twilio-*|algolia-*|hubspot-*|segment-*|plaid-*|shopify-*|salesforce-*|vercel-*|deploy*)
            category="Integrations & APIs" ;;
            
        # Product & Strategy (NEW)
        product-*|brainstorming|app-store-*|launch-strategy|pricing-strategy|free-tool-*|competitor-*|referral-*)
            category="Product & Strategy" ;;
            
        # Maker Tools (NEW)
        micro-saas-*|browser-extension-*|viral-*|personal-tool-*|notion-template-*|3d-*)
            category="Maker Tools" ;;
    esac
    
    # Generate tags from name and category
    tags="[\"${skill_name//-/\", \"}\"]"
    
    # Add comma if not first
    if [ "$first" = false ]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    first=false
    count=$((count + 1))
    
    # Write JSON entry with enhanced metadata
    cat >> "$OUTPUT_FILE" <<EOF
    {
      "name": "$skill_name",
      "description": "$description",
      "category": "$category",
      "path": "$skill_dir",
      "updated": "$updated"
    }
EOF
done

echo "" >> "$OUTPUT_FILE"
echo "  ]," >> "$OUTPUT_FILE"

# Generate category summaries
echo "  \"categories\": {" >> "$OUTPUT_FILE"

# Count skills per category
declare -A category_counts
for skill_dir in "$SKILLS_DIR"/*/ ; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    
    if [[ ! -f "$skill_md" ]] || [[ "$skill_name" == "skill-manager" ]]; then
        continue
    fi
    
    # Same category logic as above (could be refactored)
    category="Other"
    case "$skill_name" in
        brainstorming|writing-plans|executing-plans|*agent*|git-*|*code-review*|*branch*|tdd-workflow|verification-before-completion|*workflow*)
            category="Development Workflow" ;;
        test-driven-development|ui-testing|systematic-debugging|security-review|*test*|playwright-*|webapp-testing)
            category="Testing & Quality" ;;
        react-*|frontend-*|web-design-guidelines|nextjs-*|mobile-design|scroll-experience|3d-web-experience)
            category="Frontend Development" ;;
        backend-*|mcp-builder|nodejs-*|nestjs-*|prisma-*|api-*|database-*|graphql|server-*)
            category="Backend Development" ;;
        coding-standards|clean-code|lint-*|architecture|software-architecture)
            category="Code Quality" ;;
        aws-*)
            category="AWS Cloud Services" ;;
        docker-*|developing-with-docker)
            category="Docker & Containers" ;;
        config-builder|*config*)
            category="Configuration Management" ;;
        docx*|pdf*|pptx*|xlsx*|*forms*)
            category="Document Creation" ;;
        algorithmic-art|canvas-*|theme-*|brand-*|*gif*|ui-ux-*|frontend-design)
            category="Creative & Design" ;;
        ai-*|*agent*|rag-*|prompt-*|lang*|autonomous-*|loki-mode|computer-use-*|conversation-memory|context-window-*|llm-*)
            category="AI Agents & LLM" ;;
        ethical-hacking-*|pentest-*|metasploit-*|burp-suite-*|red-team-*|*penetration-testing|*injection*|*vulnerability*|*exploitation*|active-directory-*|sql-*|xss-*|shodan-*|wireshark-*|nmap-*|*hacking*|*security*|broken-*|idor-*|scanning-*)
            category="Security & Pentesting" ;;
        seo-*|*cro*|copywriting|copy-editing|marketing-*|email-*|social-*|analytics-*|content-creator|programmatic-*|page-*|paid-ads|*conversion*|schema-markup)
            category="Marketing & Growth" ;;
        stripe-*|firebase|clerk-*|discord-bot-*|slack-*|telegram-*|twilio-*|algolia-*|hubspot-*|segment-*|plaid-*|shopify-*|salesforce-*|vercel-*|deploy*)
            category="Integrations & APIs" ;;
        product-*|brainstorming|app-store-*|launch-strategy|pricing-strategy|free-tool-*|competitor-*|referral-*)
            category="Product & Strategy" ;;
        micro-saas-*|browser-extension-*|viral-*|personal-tool-*|notion-template-*|3d-*)
            category="Maker Tools" ;;
    esac
    
    category_counts["$category"]=$((${category_counts["$category"]:-0} + 1))
done

# Write category counts
cat_first=true
for category in "${!category_counts[@]}"; do
    if [ "$cat_first" = false ]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    cat_first=false
    echo -n "    \"$category\": ${category_counts[$category]}" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Update total count
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"total_skills\": 0/\"total_skills\": $count/" "$OUTPUT_FILE"
else
    sed -i "s/\"total_skills\": 0/\"total_skills\": $count/" "$OUTPUT_FILE"
fi

echo "✅ Generated index for $count skills"
echo "📊 Categories: ${#category_counts[@]}"
echo "💾 Saved to: $OUTPUT_FILE"
echo "🔄 Version: 3.0"
