#!/bin/bash

# Japanese Email Skill - Version Comparison Test
# Compares: No skill vs V1 (English) vs V2 (Japanese)

set -e

SKILL_V1="/Users/ronantakizawa/Documents/projects/skills/japanese-email"
SKILL_V2="/Users/ronantakizawa/Documents/projects/skills/japanese-email-v2"
SKILL_DEST="$HOME/.claude/skills/japanese-email"
OUTPUT_DIR="$SKILL_V1/tests/comparison-output"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$OUTPUT_DIR"

# Test prompts in both English and Japanese
PROMPTS=(
    "Write a Japanese business email to Tanaka-san requesting a meeting next week to discuss the new project proposal."
    "田中様に新しいプロジェクトの提案について来週打ち合わせをお願いするビジネスメールを書いてください。"
    "Write a Japanese email apologizing for a delayed shipment to a client."
    "Write a polite Japanese email declining a business proposal from a vendor."
    "取引先に見積書を送付するビジネスメールを書いてください。"
)

PROMPT_NAMES=(
    "01-meeting-request-en"
    "02-meeting-request-jp"
    "03-apology-delay"
    "04-decline-proposal"
    "05-quotation-jp"
)

echo "=============================================="
echo "Japanese Email Skill - Version Comparison Test"
echo "=============================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo "Timestamp: $TIMESTAMP"
echo ""

# Function to run a single prompt
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
echo "PHASE 1: Testing WITHOUT skill"
echo "------------------------------"

# Remove any existing skill
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

    echo "    Saved to: $output_file"
done

echo ""
echo "Phase 1 complete."
echo ""

# ============================================
# PHASE 2: Test WITH V1 skill (English)
# ============================================
echo "PHASE 2: Testing WITH V1 skill (English explanations)"
echo "-----------------------------------------------------"

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

    echo "    Saved to: $output_file"
done

rm -rf "$SKILL_DEST"

echo ""
echo "Phase 2 complete."
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

    echo "    Saved to: $output_file"
done

rm -rf "$SKILL_DEST"

echo ""
echo "Phase 3 complete."
echo ""

# ============================================
# PHASE 4: Generate comparison file
# ============================================
echo "PHASE 4: Generating comparison file"
echo "------------------------------------"

COMPARISON_FILE="$OUTPUT_DIR/$TIMESTAMP-comparison.md"

{
    echo "# Japanese Email Skill - Version Comparison"
    echo ""
    echo "**Date:** $(date)"
    echo "**Test:** Comparing no skill vs V1 (English) vs V2 (Japanese)"
    echo ""
    echo "## Scoring Guide"
    echo ""
    echo "Rate each response on these criteria (1-5):"
    echo ""
    echo "| Criteria | Description |"
    echo "|----------|-------------|"
    echo "| **Keigo Accuracy** | Correct use of 尊敬語/謙譲語/丁寧語 |"
    echo "| **Structure** | Follows 7-part email format |"
    echo "| **Natural Japanese** | Reads naturally to native speaker |"
    echo "| **Appropriate Formality** | Matches business context |"
    echo "| **Completeness** | Includes all necessary elements |"
    echo ""
    echo "## Results Summary"
    echo ""
    echo "| Test | No Skill | V1 (English) | V2 (Japanese) |"
    echo "|------|----------|--------------|---------------|"
    echo "| 1. Meeting Request (EN) | | | |"
    echo "| 2. Meeting Request (JP) | | | |"
    echo "| 3. Apology for Delay | | | |"
    echo "| 4. Decline Proposal | | | |"
    echo "| 5. Quotation (JP) | | | |"
    echo "| **Average** | | | |"
    echo ""
    echo "---"
    echo ""
} > "$COMPARISON_FILE"

# Add side-by-side comparisons
for i in "${!PROMPT_NAMES[@]}"; do
    name="${PROMPT_NAMES[$i]}"

    {
        echo "## Test $((i+1)): ${name//-/ }"
        echo ""
        echo "**Your Scores:** No Skill [ ] | V1 [ ] | V2 [ ]"
        echo ""
        echo "### Prompt"
        echo "\`\`\`"
        echo "${PROMPTS[$i]}"
        echo "\`\`\`"
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
        echo "### Notes"
        echo ""
        echo "_Compare keigo usage, structure, and naturalness_"
        echo ""
        echo "---"
        echo ""
    } >> "$COMPARISON_FILE"
done

{
    echo "## Overall Assessment"
    echo ""
    echo "### Winner: [ ] No Skill | [ ] V1 (English) | [ ] V2 (Japanese)"
    echo ""
    echo "### Observations"
    echo ""
    echo "- Keigo accuracy:"
    echo "- Email structure:"
    echo "- Natural Japanese:"
    echo "- Other notes:"
    echo ""
} >> "$COMPARISON_FILE"

echo "Comparison file: $COMPARISON_FILE"
echo ""

# ============================================
# Done
# ============================================
echo "=============================================="
echo "COMPARISON TEST COMPLETE"
echo "=============================================="
echo ""
echo "Output files:"
echo "  No skill:    $NO_SKILL_DIR/"
echo "  V1 English:  $V1_DIR/"
echo "  V2 Japanese: $V2_DIR/"
echo "  Comparison:  $COMPARISON_FILE"
echo ""
echo "Next steps:"
echo "  1. Open $COMPARISON_FILE"
echo "  2. Review each response trio"
echo "  3. Score using the criteria (1-5)"
echo "  4. Determine which version performs best"
echo ""
