#!/bin/bash

# Japanese Email Skill - HARD Version Comparison Test
# More challenging scenarios to differentiate skill performance

set -e

SKILL_V1="/Users/ronantakizawa/Documents/projects/skills/japanese-email"
SKILL_V2="/Users/ronantakizawa/Documents/projects/skills/japanese-email-v2"
SKILL_DEST="$HOME/.claude/skills/japanese-email"
OUTPUT_DIR="$SKILL_V1/tests/comparison-hard-output"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$OUTPUT_DIR"

# HARD test prompts - more complex scenarios
PROMPTS=(
    # 1. Complex keigo - multiple ranks
    "Write a Japanese business email to client CEO Yamamoto-shacho, CC'ing your own boss Suzuki-bucho, apologizing that the product demo scheduled for tomorrow must be postponed due to a technical issue. You need to propose new dates while being appropriately humble to the CEO and respectful of your boss being CC'd."

    # 2. Multi-purpose email
    "Write a Japanese email that does all of these: (1) thank Tanaka-san for the meeting last week, (2) apologize that your follow-up is 5 days late, (3) attach the revised proposal as discussed, (4) note one price change from the meeting, and (5) request a follow-up meeting next week."

    # 3. Delicate payment reminder
    "Write a Japanese business email to a long-term client whose payment is 30 days overdue. This is your second reminder. You must be firm but preserve the 10-year business relationship. The amount is ¥500,000."

    # 4. Fix keigo errors
    "この日本語ビジネスメールの敬語の間違いを直してください：

件名：明日の会議
田中さん
お疲れ様です。
明日の会議に私がいらっしゃいます。資料を見てください。
ご飯を食べた後に始めましょう。
よろしく。
山田"

    # 5. Condolence email (very strict rules)
    "Write a Japanese condolence business email (お悔やみメール) to a client Sato-san whose father passed away. This requires very specific language and must avoid certain taboo words/phrases."

    # 6. Decline while suggesting alternative
    "Write a Japanese email declining a project request from an important client because your team is at capacity, but suggest your trusted partner company (ABC株式会社) as an alternative. You must decline gracefully while maintaining the relationship and properly introducing the alternative."

    # 7. Apologize while requesting (conflicting purposes)
    "Write a Japanese email to a vendor who delivered defective parts. You must: (1) firmly but politely report the quality issue, (2) request replacement parts urgently, (3) ask for a discount on this order due to the trouble caused, while (4) maintaining the business relationship for future orders."
)

PROMPT_NAMES=(
    "01-complex-keigo-multi-rank"
    "02-multi-purpose-email"
    "03-payment-reminder-delicate"
    "04-fix-keigo-errors"
    "05-condolence-email"
    "06-decline-with-alternative"
    "07-complain-and-request"
)

echo "=============================================="
echo "Japanese Email Skill - HARD Comparison Test"
echo "=============================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo "Timestamp: $TIMESTAMP"
echo ""

run_prompt() {
    local prompt="$1"
    local output_file="$2"
    echo "$prompt" | claude --print 2>/dev/null > "$output_file" || {
        echo "[ERROR] Failed to run prompt"
        echo "[ERROR] Failed to get response" > "$output_file"
    }
}

# ============================================
# PHASE 1: Test WITHOUT skill
# ============================================
echo "PHASE 1: Testing WITHOUT skill (7 hard prompts)"
echo "------------------------------------------------"

rm -rf "$SKILL_DEST" 2>/dev/null || true

NO_SKILL_DIR="$OUTPUT_DIR/$TIMESTAMP-no-skill"
mkdir -p "$NO_SKILL_DIR"

for i in "${!PROMPTS[@]}"; do
    name="${PROMPT_NAMES[$i]}"
    prompt="${PROMPTS[$i]}"
    output_file="$NO_SKILL_DIR/$name.md"

    echo "  Running test $((i+1))/${#PROMPTS[@]}: $name"

    {
        echo "# Test: $name (No Skill)"
        echo ""
        echo "**Prompt:**"
        echo "\`\`\`"
        echo "$prompt"
        echo "\`\`\`"
        echo ""
        echo "**Response:**"
        echo ""
    } > "$output_file"

    run_prompt "$prompt" "$output_file.tmp"
    cat "$output_file.tmp" >> "$output_file"
    rm "$output_file.tmp"
done

echo "  Phase 1 complete."
echo ""

# ============================================
# PHASE 2: Test WITH V1 skill (English)
# ============================================
echo "PHASE 2: Testing WITH V1 skill (English)"
echo "-----------------------------------------"

mkdir -p "$(dirname "$SKILL_DEST")"
cp -r "$SKILL_V1" "$SKILL_DEST"

V1_DIR="$OUTPUT_DIR/$TIMESTAMP-v1-english"
mkdir -p "$V1_DIR"

for i in "${!PROMPTS[@]}"; do
    name="${PROMPT_NAMES[$i]}"
    prompt="${PROMPTS[$i]}"
    output_file="$V1_DIR/$name.md"

    echo "  Running test $((i+1))/${#PROMPTS[@]}: $name"

    {
        echo "# Test: $name (V1 - English)"
        echo ""
        echo "**Prompt:**"
        echo "\`\`\`"
        echo "$prompt"
        echo "\`\`\`"
        echo ""
        echo "**Response:**"
        echo ""
    } > "$output_file"

    run_prompt "$prompt" "$output_file.tmp"
    cat "$output_file.tmp" >> "$output_file"
    rm "$output_file.tmp"
done

rm -rf "$SKILL_DEST"
echo "  Phase 2 complete."
echo ""

# ============================================
# PHASE 3: Test WITH V2 skill (Japanese)
# ============================================
echo "PHASE 3: Testing WITH V2 skill (Japanese)"
echo "------------------------------------------"

cp -r "$SKILL_V2" "$SKILL_DEST"

V2_DIR="$OUTPUT_DIR/$TIMESTAMP-v2-japanese"
mkdir -p "$V2_DIR"

for i in "${!PROMPTS[@]}"; do
    name="${PROMPT_NAMES[$i]}"
    prompt="${PROMPTS[$i]}"
    output_file="$V2_DIR/$name.md"

    echo "  Running test $((i+1))/${#PROMPTS[@]}: $name"

    {
        echo "# Test: $name (V2 - Japanese)"
        echo ""
        echo "**Prompt:**"
        echo "\`\`\`"
        echo "$prompt"
        echo "\`\`\`"
        echo ""
        echo "**Response:**"
        echo ""
    } > "$output_file"

    run_prompt "$prompt" "$output_file.tmp"
    cat "$output_file.tmp" >> "$output_file"
    rm "$output_file.tmp"
done

rm -rf "$SKILL_DEST"
echo "  Phase 3 complete."
echo ""

# ============================================
# PHASE 4: Generate comparison file
# ============================================
echo "PHASE 4: Generating comparison file"
echo "------------------------------------"

COMPARISON_FILE="$OUTPUT_DIR/$TIMESTAMP-comparison-hard.md"

{
    echo "# Japanese Email Skill - HARD Test Comparison"
    echo ""
    echo "**Date:** $(date)"
    echo "**Test Type:** Difficult scenarios requiring nuanced keigo and cultural knowledge"
    echo ""
    echo "## Scoring Criteria (1-5 each)"
    echo ""
    echo "| Criteria | Description |"
    echo "|----------|-------------|"
    echo "| **Keigo Accuracy** | Correct 尊敬語/謙譲語/丁寧語 for all parties |"
    echo "| **Cultural Appropriateness** | Follows Japanese business customs |"
    echo "| **Tone Balance** | Handles conflicting purposes gracefully |"
    echo "| **Completeness** | Addresses all requirements in prompt |"
    echo "| **Natural Japanese** | Reads naturally to native speaker |"
    echo ""
    echo "## Test Descriptions"
    echo ""
    echo "1. **Complex Keigo** - Email to client CEO, CC'ing own boss"
    echo "2. **Multi-Purpose** - 5 things in one email"
    echo "3. **Payment Reminder** - Firm but relationship-preserving"
    echo "4. **Fix Keigo Errors** - Correct mistakes in given email"
    echo "5. **Condolence** - Very strict cultural rules"
    echo "6. **Decline + Alternative** - Graceful refusal with suggestion"
    echo "7. **Complain + Request** - Report issue while requesting help"
    echo ""
    echo "## Results Summary"
    echo ""
    echo "| Test | No Skill | V1 (EN) | V2 (JP) | Winner |"
    echo "|------|----------|---------|---------|--------|"
    echo "| 1. Complex Keigo | /25 | /25 | /25 | |"
    echo "| 2. Multi-Purpose | /25 | /25 | /25 | |"
    echo "| 3. Payment Reminder | /25 | /25 | /25 | |"
    echo "| 4. Fix Keigo | /25 | /25 | /25 | |"
    echo "| 5. Condolence | /25 | /25 | /25 | |"
    echo "| 6. Decline+Alt | /25 | /25 | /25 | |"
    echo "| 7. Complain+Request | /25 | /25 | /25 | |"
    echo "| **TOTAL** | /175 | /175 | /175 | |"
    echo ""
    echo "---"
    echo ""
} > "$COMPARISON_FILE"

# Add detailed comparisons
for i in "${!PROMPT_NAMES[@]}"; do
    name="${PROMPT_NAMES[$i]}"

    {
        echo "## Test $((i+1)): ${name//-/ }"
        echo ""
        echo "### Prompt"
        echo "\`\`\`"
        echo "${PROMPTS[$i]}"
        echo "\`\`\`"
        echo ""
        echo "### Scores"
        echo "| Version | Keigo | Cultural | Tone | Complete | Natural | Total |"
        echo "|---------|-------|----------|------|----------|---------|-------|"
        echo "| No Skill | | | | | | /25 |"
        echo "| V1 (EN) | | | | | | /25 |"
        echo "| V2 (JP) | | | | | | /25 |"
        echo ""
        echo "### No Skill Response"
        echo ""
        tail -n +10 "$NO_SKILL_DIR/$name.md" 2>/dev/null || echo "[No response]"
        echo ""
        echo "### V1 (English) Response"
        echo ""
        tail -n +10 "$V1_DIR/$name.md" 2>/dev/null || echo "[No response]"
        echo ""
        echo "### V2 (Japanese) Response"
        echo ""
        tail -n +10 "$V2_DIR/$name.md" 2>/dev/null || echo "[No response]"
        echo ""
        echo "### Analysis"
        echo ""
        echo "_Notes on keigo accuracy, cultural appropriateness, and differences:_"
        echo ""
        echo "---"
        echo ""
    } >> "$COMPARISON_FILE"
done

echo "Comparison file: $COMPARISON_FILE"
echo ""
echo "=============================================="
echo "HARD COMPARISON TEST COMPLETE"
echo "=============================================="
echo ""
echo "Output:"
echo "  No skill:   $NO_SKILL_DIR/"
echo "  V1 English: $V1_DIR/"
echo "  V2 Japanese: $V2_DIR/"
echo "  Comparison: $COMPARISON_FILE"
echo ""
