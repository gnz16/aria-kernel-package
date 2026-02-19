#!/bin/bash
# Track skill usage: activation, completion, or failure
# Usage: track-skill.sh <skill-name> <event> [tokens]

METRICS_FILE="$HOME/.gemini/skills/skill-manager/data/skill_metrics.json"

skill_name="$1"
event="$2"
tokens="${3:-0}"

if [ -z "$skill_name" ] || [ -z "$event" ]; then
    echo "Usage: track-skill.sh <skill-name> <event> [tokens]"
    echo "Events: activation, completion, failure"
    exit 1
fi

if [ ! -f "$METRICS_FILE" ]; then
    echo "Error: Metrics file not found. Run init-metrics.sh first."
    exit 1
fi

current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

case "$event" in
    activation)
        jq --arg skill "$skill_name" \
           --arg time "$current_time" \
           '.skills[$skill].activations += 1 | 
            .skills[$skill].last_used = $time |
            .last_updated = $time' \
           "$METRICS_FILE" > tmp.json && mv tmp.json "$METRICS_FILE"
        echo "✓ Tracked activation for $skill_name"
        ;;
        
    completion)
        jq --arg skill "$skill_name" \
           --argjson tokens "$tokens" \
           --arg time "$current_time" \
           '.skills[$skill].completions += 1 |
            .skills[$skill].total_tokens += $tokens |
            .skills[$skill].avg_tokens = (.skills[$skill].total_tokens / .skills[$skill].activations) |
            .skills[$skill].success_rate = (.skills[$skill].completions / .skills[$skill].activations) |
            .last_updated = $time' \
           "$METRICS_FILE" > tmp.json && mv tmp.json "$METRICS_FILE"
        echo "✓ Tracked completion for $skill_name ($tokens tokens)"
        ;;
        
    failure)
        jq --arg skill "$skill_name" \
           --arg time "$current_time" \
           '.skills[$skill].failures += 1 |
            .skills[$skill].success_rate = (.skills[$skill].completions / .skills[$skill].activations) |
            .last_updated = $time' \
           "$METRICS_FILE" > tmp.json && mv tmp.json "$METRICS_FILE"
        echo "✓ Tracked failure for $skill_name"
        ;;
        
    *)
        echo "Error: Unknown event '$event'"
        echo "Valid events: activation, completion, failure"
        exit 1
        ;;
esac
