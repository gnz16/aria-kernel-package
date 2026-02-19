import { writeFileSync, mkdirSync } from 'fs';
import { dirname } from 'path';
import chalk from 'chalk';
import type { MasterTestReport, TestSuiteResult, TestStatus } from './types.js';

/**
 * ReportGenerator - Generates test execution reports
 * Mirrors the C# ReportGenerator functionality
 */
export class ReportGenerator {
    /**
     * Generate comprehensive test report
     */
    generateReport(report: MasterTestReport): void {
        this.printConsoleSummary(report);
        this.generateHTMLReport(report);
        this.generateJSONReport(report);
    }

    /**
     * Print summary to console
     */
    private printConsoleSummary(report: MasterTestReport): void {
        console.log('\n' + chalk.cyan('╔════════════════════════════════════════════════╗'));
        console.log(chalk.cyan('║              TEST EXECUTION SUMMARY            ║'));
        console.log(chalk.cyan('╚════════════════════════════════════════════════╝'));

        console.log(`\nExecution Time: ${chalk.yellow((report.duration / 1000).toFixed(2))}s`);
        console.log(`Total Tests: ${chalk.blue(report.totalTests)}`);
        console.log(chalk.green(`Passed: ${report.passedTests}`));

        if (report.failedTests > 0) {
            console.log(chalk.red(`Failed: ${report.failedTests}`));
        }

        const passRateColor = report.passRate >= 90 ? chalk.green :
            report.passRate >= 70 ? chalk.yellow : chalk.red;
        console.log(`Pass Rate: ${passRateColor(report.passRate.toFixed(1) + '%')}`);
    }

    /**
     * Generate HTML report
     */
    private generateHTMLReport(report: MasterTestReport): void {
        const html = `<!DOCTYPE html>
<html>
<head>
    <title>Test Report - ${new Date().toISOString()}</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 20px;
        }
        .header h1 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
        }
        .header p {
            color: #64748b;
        }
        .summary {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 20px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .stat {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            border-radius: 8px;
            color: white;
            text-align: center;
        }
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
            margin-bottom: 5px;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
        }
        .stat.success { background: linear-gradient(135deg, #10b981 0%, #059669 100%); }
        .stat.danger { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); }
        .stat.info { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); }
        .suite {
            background: white;
            padding: 25px;
            margin: 15px 0;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border-left: 5px solid #667eea;
        }
        .suite h3 {
            color: #1e293b;
            margin-bottom: 15px;
            font-size: 20px;
        }
        .suite-meta {
            color: #64748b;
            margin-bottom: 15px;
            font-size: 14px;
        }
        .test-list {
            list-style: none;
        }
        .test-item {
            padding: 12px;
            margin: 8px 0;
            border-radius: 6px;
            border-left: 3px solid;
            background: #f8fafc;
        }
        .test-pass {
            border-left-color: #10b981;
            background: #f0fdf4;
        }
        .test-fail {
            border-left-color: #ef4444;
            background: #fef2f2;
        }
        .test-name {
            font-weight: 600;
            margin-bottom: 4px;
        }
        .test-pass .test-name { color: #059669; }
        .test-fail .test-name { color: #dc2626; }
        .test-meta {
            font-size: 12px;
            color: #64748b;
        }
        .test-error {
            margin-top: 8px;
            padding: 8px;
            background: white;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            color: #dc2626;
        }
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            margin-left: 8px;
        }
        .badge-success { background: #d1fae5; color: #065f46; }
        .badge-danger { background: #fee2e2; color: #991b1b; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 Web UI Test Report</h1>
            <p>Generated: ${new Date().toLocaleString()}</p>
        </div>
        
        <div class="summary">
            <h2>Execution Summary</h2>
            <div class="stats">
                <div class="stat info">
                    <div class="stat-label">Total Tests</div>
                    <div class="stat-value">${report.totalTests}</div>
                </div>
                <div class="stat success">
                    <div class="stat-label">Passed</div>
                    <div class="stat-value">${report.passedTests}</div>
                </div>
                <div class="stat danger">
                    <div class="stat-label">Failed</div>
                    <div class="stat-value">${report.failedTests}</div>
                </div>
                <div class="stat">
                    <div class="stat-label">Pass Rate</div>
                    <div class="stat-value">${report.passRate.toFixed(1)}%</div>
                </div>
                <div class="stat">
                    <div class="stat-label">Duration</div>
                    <div class="stat-value">${(report.duration / 1000).toFixed(1)}s</div>
                </div>
            </div>
        </div>
        
        <h2 style="color: white; margin: 30px 0 15px;">Test Suites</h2>
        ${this.generateSuiteHTML(report.suiteResults)}
    </div>
</body>
</html>`;

        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
        const reportPath = `${report.configuration.reportPath}/report_${timestamp}.html`;

        mkdirSync(dirname(reportPath), { recursive: true });
        writeFileSync(reportPath, html, 'utf-8');

        console.log(chalk.cyan(`\n📊 HTML Report: ${reportPath}`));
    }

    /**
     * Generate suite HTML for report
     */
    private generateSuiteHTML(suites: TestSuiteResult[]): string {
        return suites.map(suite => `
        <div class="suite">
            <h3>
                ${suite.suiteName}
                <span class="badge badge-success">${suite.passedCount} passed</span>
                ${suite.failedCount > 0 ? `<span class="badge badge-danger">${suite.failedCount} failed</span>` : ''}
            </h3>
            <div class="suite-meta">
                Duration: ${(suite.duration / 1000).toFixed(2)}s | 
                Tests: ${suite.testResults.length}
            </div>
            <ul class="test-list">
                ${suite.testResults.map(test => `
                    <li class="test-item test-${test.status === 'PASSED' ? 'pass' : 'fail'}">
                        <div class="test-name">
                            ${test.status === 'PASSED' ? '✓' : '✗'} ${test.testName}
                        </div>
                        <div class="test-meta">
                            Duration: ${(test.duration / 1000).toFixed(2)}s
                            ${test.attempts > 1 ? ` | Attempts: ${test.attempts}` : ''}
                        </div>
                        ${test.message && test.status === 'FAILED' ? `
                            <div class="test-error">${test.message}</div>
                        ` : ''}
                    </li>
                `).join('')}
            </ul>
        </div>
    `).join('');
    }

    /**
     * Generate JSON report for programmatic analysis
     */
    private generateJSONReport(report: MasterTestReport): void {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
        const reportPath = `${report.configuration.reportPath}/report_${timestamp}.json`;

        mkdirSync(dirname(reportPath), { recursive: true });
        writeFileSync(reportPath, JSON.stringify(report, null, 2), 'utf-8');

        console.log(chalk.gray(`📄 JSON Report: ${reportPath}`));
    }
}
