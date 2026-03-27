import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-checkins',
  standalone: true,
  imports: [CommonModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header"><h1>Check-ins</h1></div>
      @if (loading()) { <app-loading-spinner /> }
      @else { <app-data-table [columns]="columns" [data]="tableData()" /> }
    </div>
  `,
  styles: [`.page { padding: 32px; } .page-header h1 { color: #fff; font-size: 24px; margin: 0 0 24px; }`]
})
export class CheckinsComponent implements OnInit {
  loading = signal(true);
  tableData = signal<Record<string, unknown>[]>([]);
  columns: TableColumn[] = [
    { key: 'user_id', label: 'User ID' },
    { key: 'gym_id', label: 'Gym ID' },
    { key: 'plan_tier', label: 'Plan Tier', type: 'badge', badgeColors: { silver: '#888', gold: '#FFD60A', platinum: '#AF52DE', diamond: '#00D4FF' } },
    { key: 'daily_rate_paid', label: 'Rate Paid' },
    { key: 'status', label: 'Status', type: 'badge', badgeColors: { completed: '#00FF88', pending: '#FFD60A' } },
    { key: 'checked_in_at', label: 'Time', type: 'date' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void {
    this.adminService.getCheckins(0, 100).subscribe({
      next: (data) => { this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }
}
