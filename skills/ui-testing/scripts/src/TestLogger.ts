import chalk from 'chalk';
import { writeFileSync } from 'fs';
import type { LogEntry } from './types.js';

/**
 * TestLogger - Handles logging with colored console output
 * Mirrors the C# TestLogger functionality
 */
export class TestLogger {
    private logs: LogEntry[] = [];

    /**
     * Log an informational message
     */
    log(message: string): void {
        const entry: LogEntry = {
            timestamp: new Date(),
            level: 'info',
            message
        };
        this.logs.push(entry);
        const formattedTime = this.formatTime(entry.timestamp);
        console.log(chalk.gray(`[${formattedTime}]`), message);
    }

    /**
     * Log a success message (green checkmark)
     */
    logSuccess(message: string): void {
        const entry: LogEntry = {
            timestamp: new Date(),
            level: 'success',
            message
        };
        this.logs.push(entry);
        const formattedTime = this.formatTime(entry.timestamp);
        console.log(chalk.gray(`[${formattedTime}]`), chalk.green('✓'), chalk.green(message));
    }

    /**
     * Log an error message (red X)
     */
    logError(message: string): void {
        const entry: LogEntry = {
            timestamp: new Date(),
            level: 'error',
            message
        };
        this.logs.push(entry);
        const formattedTime = this.formatTime(entry.timestamp);
        console.log(chalk.gray(`[${formattedTime}]`), chalk.red('✗'), chalk.red(message));
    }

    /**
     * Log a warning message (yellow exclamation)
     */
    logWarning(message: string): void {
        const entry: LogEntry = {
            timestamp: new Date(),
            level: 'warning',
            message
        };
        this.logs.push(entry);
        const formattedTime = this.formatTime(entry.timestamp);
        console.log(chalk.gray(`[${formattedTime}]`), chalk.yellow('⚠'), chalk.yellow(message));
    }

    /**
     * Get all log entries
     */
    getLogs(): LogEntry[] {
        return [...this.logs];
    }

    /**
     * Save logs to a file
     */
    saveToFile(filePath: string): void {
        const logLines = this.logs.map(entry => {
            const time = this.formatTime(entry.timestamp);
            const symbol = this.getSymbol(entry.level);
            return `[${time}] ${symbol} ${entry.message}`;
        });
        writeFileSync(filePath, logLines.join('\n'), 'utf-8');
        this.log(`Logs saved to: ${filePath}`);
    }

    /**
     * Clear all logs
     */
    clear(): void {
        this.logs = [];
    }

    /**
     * Format timestamp as HH:MM:SS
     */
    private formatTime(date: Date): string {
        return date.toTimeString().split(' ')[0];
    }

    /**
     * Get symbol for log level
     */
    private getSymbol(level: LogEntry['level']): string {
        switch (level) {
            case 'success':
                return '✓';
            case 'error':
                return '✗';
            case 'warning':
                return '⚠';
            default:
                return ' ';
        }
    }
}
