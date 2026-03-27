import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Payments</h1>
        <select [(ngModel)]="statusFilter" (change)="load()" class="filter-select">
          <option value="">All</option>
          <option value="success">Success</option>
          <option value="pending">Pending</option>
          <option value="failed">Failed</option>
        </select>
      </div>
      @if (loading()) { <app-loading-spinner /> }
      @else { <app-data-table [columns]="columns" [data]="tableData()" /> }
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .filter-select { background: #111; border: 1px solid #333; border-radius: 8px; padding: 8px 12px; color: #fff; font-size: 14px; outline: none; }
  `]
})
export class PaymentsComponent implements OnInit {
  loading = signal(true);
  tableData = signal<Record<string, unknown>[]>([]);
  statusFilter = '';

  columns: TableColumn[] = [
    { key: 'user_id', label: 'User ID' },
    { key: 'amount_local', label: 'Amount' },
    { key: 'currency_code', label: 'Currency' },
    { key: 'gateway', label: 'Gateway' },
    { key: 'status', label: 'Status', type: 'badge', badgeColors: { success: '#00FF88', pending: '#FFD60A', failed: '#FF3B30' } },
    { key: 'paid_at', label: 'Paid At', type: 'date' },
    { key: 'created_at', label: 'Created', type: 'date' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getPayments(0, 100, this.statusFilter || undefined).subscribe({
      next: (data) => { this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }
}
