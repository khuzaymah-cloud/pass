import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { Payment } from '../../core/models';

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
      @else { <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" /> }
    </div>

    @if (showModal()) {
      <div class="modal-backdrop" (click)="showModal.set(false)">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h2>Payment Details</h2>
            <button class="close-btn" (click)="showModal.set(false)">✕</button>
          </div>
          <div class="modal-body">
            @if (selected()) {
              <div class="detail-grid">
                <div class="detail-item"><span class="label">ID</span><span class="value id-val">{{ selected()!.id }}</span></div>
                <div class="detail-item"><span class="label">User ID</span><span class="value id-val">{{ selected()!.user_id }}</span></div>
                <div class="detail-item"><span class="label">Subscription ID</span><span class="value id-val">{{ selected()!.subscription_id }}</span></div>
                <div class="detail-item"><span class="label">Amount</span><span class="value">{{ selected()!.amount_local }} {{ selected()!.currency_code }}</span></div>
                <div class="detail-item"><span class="label">VAT Rate</span><span class="value">{{ selected()!.vat_rate }}%</span></div>
                <div class="detail-item"><span class="label">VAT Amount</span><span class="value">{{ selected()!.vat_amount }} {{ selected()!.currency_code }}</span></div>
                <div class="detail-item"><span class="label">Total Charged</span><span class="value" style="color:var(--accent);font-weight:700">{{ selected()!.total_charged }} {{ selected()!.currency_code }}</span></div>
                <div class="detail-item"><span class="label">Gateway</span><span class="value">{{ selected()!.gateway }}</span></div>
                <div class="detail-item"><span class="label">Gateway Ref</span><span class="value">{{ selected()!.gateway_ref || '—' }}</span></div>
                <div class="detail-item"><span class="label">Status</span><span class="value badge" [style.color]="statusColor(selected()!.status)">{{ selected()!.status }}</span></div>
                <div class="detail-item"><span class="label">Paid At</span><span class="value">{{ selected()!.paid_at ? (selected()!.paid_at | date:'medium') : '—' }}</span></div>
                <div class="detail-item"><span class="label">Created</span><span class="value">{{ selected()!.created_at | date:'medium' }}</span></div>
              </div>
            }
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .page-header h1 { color: var(--text-primary); font-size: 24px; margin: 0; }
    .filter-select { background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 8px; padding: 8px 12px; color: var(--text-primary); font-size: 14px; outline: none; }
    .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
    .modal { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--border); }
    .modal-header h2 { color: var(--text-primary); font-size: 20px; margin: 0; }
    .close-btn { background: none; border: none; color: var(--text-muted); font-size: 20px; cursor: pointer; }
    .modal-body { padding: 24px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .detail-item { display: flex; flex-direction: column; gap: 4px; }
    .label { color: var(--text-muted); font-size: 12px; font-weight: 600; text-transform: uppercase; }
    .value { color: var(--text-primary); font-size: 14px; } .id-val { font-size: 11px; color: #666; word-break: break-all; }
    .badge { font-weight: 700; }
  `]
})
export class PaymentsComponent implements OnInit {
  loading = signal(true);
  payments = signal<Payment[]>([]);
  tableData = signal<Record<string, unknown>[]>([]);
  statusFilter = '';
  showModal = signal(false);
  selected = signal<Payment | null>(null);

  columns: TableColumn[] = [
    { key: 'user_id', label: 'User ID' },
    { key: 'amount_local', label: 'Amount' },
    { key: 'currency_code', label: 'Currency' },
    { key: 'gateway', label: 'Gateway' },
    { key: 'status', label: 'Status', type: 'badge', badgeColors: { success: 'var(--success)', pending: 'var(--warning)', failed: 'var(--error)' } },
    { key: 'paid_at', label: 'Paid At', type: 'date' },
    { key: 'created_at', label: 'Created', type: 'date' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getPayments(0, 100, this.statusFilter || undefined).subscribe({
      next: (data: Payment[]) => { this.payments.set(data); this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    const item = this.payments().find(p => p.id === id);
    if (item && (event.action === 'view' || event.action === 'edit')) { this.selected.set(item); this.showModal.set(true); }
  }

  statusColor(s: string): string { return ({ success: 'var(--success)', pending: 'var(--warning)', failed: 'var(--error)' } as Record<string, string>)[s] || 'var(--text-muted)'; }
}
