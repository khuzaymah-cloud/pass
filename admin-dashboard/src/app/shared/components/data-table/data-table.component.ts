import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface TableColumn {
  key: string;
  label: string;
  type?: 'text' | 'badge' | 'date' | 'boolean' | 'actions';
  badgeColors?: Record<string, string>;
}

@Component({
  selector: 'app-data-table',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            @for (col of columns; track col.key) {
              <th>{{ col.label }}</th>
            }
          </tr>
        </thead>
        <tbody>
          @for (row of data; track trackByFn(row)) {
            <tr>
              @for (col of columns; track col.key) {
                <td>
                  @switch (col.type) {
                    @case ('badge') {
                      <span class="badge" [style.background]="getBadgeColor(col, row[col.key]) + '22'" [style.color]="getBadgeColor(col, row[col.key])">
                        {{ row[col.key] }}
                      </span>
                    }
                    @case ('boolean') {
                      <span class="badge" [style.background]="row[col.key] ? '#00FF8822' : '#FF3B3022'" [style.color]="row[col.key] ? '#00FF88' : '#FF3B30'">
                        {{ row[col.key] ? 'Yes' : 'No' }}
                      </span>
                    }
                    @case ('date') {
                      {{ row[col.key] ? ($any(row[col.key]) | date:'short') : '—' }}
                    }
                    @case ('actions') {
                      <div class="actions">
                        <button class="action-btn" (click)="action.emit({action: 'view', row})">👁</button>
                        <button class="action-btn" (click)="action.emit({action: 'edit', row})">✏️</button>
                        <button class="action-btn danger" (click)="action.emit({action: 'delete', row})">🗑</button>
                      </div>
                    }
                    @default {
                      <span class="cell-text" [title]="row[col.key]">{{ row[col.key] ?? '—' }}</span>
                    }
                  }
                </td>
              }
            </tr>
          }
          @if (data.length === 0) {
            <tr><td [attr.colspan]="columns.length" class="empty">No data found</td></tr>
          }
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    .table-wrapper {
      overflow-x: auto;
      border-radius: 12px;
      border: 1px solid #1a1a1a;
      background: #111;
    }
    .data-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }
    th {
      text-align: left;
      padding: 12px 16px;
      color: #888;
      font-weight: 600;
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      border-bottom: 1px solid #1a1a1a;
      background: #0a0a0a;
      white-space: nowrap;
    }
    td {
      padding: 12px 16px;
      color: #ccc;
      border-bottom: 1px solid #1a1a1a;
    }
    tr:hover td { background: #1a1a1a; }
    .badge {
      padding: 4px 10px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      white-space: nowrap;
    }
    .cell-text {
      max-width: 200px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      display: inline-block;
    }
    .actions { display: flex; gap: 6px; }
    .action-btn {
      background: #1a1a1a;
      border: 1px solid #333;
      border-radius: 6px;
      cursor: pointer;
      padding: 4px 8px;
      font-size: 14px;
      transition: all 0.2s;
    }
    .action-btn:hover { background: #2a2a2a; }
    .action-btn.danger:hover { background: rgba(255,59,48,0.2); }
    .empty { text-align: center; color: #666; padding: 32px; }
  `]
})
export class DataTableComponent {
  @Input() columns: TableColumn[] = [];
  @Input() data: Record<string, unknown>[] = [];
  @Output() action = new EventEmitter<{ action: string; row: Record<string, unknown> }>();

  trackByFn(row: Record<string, unknown>): string {
    return (row['id'] as string) ?? '';
  }

  getBadgeColor(col: TableColumn, value: unknown): string {
    const colors = col.badgeColors ?? {};
    return colors[String(value)] ?? '#888';
  }
}
