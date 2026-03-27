import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-settlements',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Gym Settlements</h1>
        <div class="filters">
          <select [(ngModel)]="statusFilter" (change)="load()" class="filter-select">
            <option value="">All</option>
            <option value="pending">Pending</option>
            <option value="paid">Paid</option>
          </select>
          <button class="btn-action" (click)="runSettlement()">🔄 Run Settlement</button>
        </div>
      </div>
      @if (loading()) { <app-loading-spinner /> }
      @else { <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" /> }
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; }
    .filter-select { background: #111; border: 1px solid #333; border-radius: 8px; padding: 8px 12px; color: #fff; font-size: 14px; outline: none; }
    .btn-action { background: #00FF88; color: #000; border: none; border-radius: 8px; padding: 8px 16px; font-weight: 600; cursor: pointer; font-size: 13px; }
  `]
})
export class SettlementsComponent implements OnInit {
  loading = signal(true);
  tableData = signal<Record<string, unknown>[]>([]);
  statusFilter = '';

  columns: TableColumn[] = [
    { key: 'gym_id', label: 'Gym ID' },
    { key: 'total_visits', label: 'Visits' },
    { key: 'total_amount', label: 'Amount (JD)' },
    { key: 'status', label: 'Status', type: 'badge', badgeColors: { pending: '#FFD60A', paid: '#00FF88' } },
    { key: 'period_start', label: 'Period Start' },
    { key: 'period_end', label: 'Period End' },
    { key: 'paid_at', label: 'Paid At', type: 'date' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getSettlements(0, 100, this.statusFilter || undefined).subscribe({
      next: (data) => { this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  runSettlement(): void {
    this.adminService.runSettlement().subscribe(() => this.load());
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    if (event.action === 'edit') {
      this.adminService.markSettlementPaid(id).subscribe(() => this.load());
    }
  }
}
