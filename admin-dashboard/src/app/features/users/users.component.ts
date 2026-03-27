import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { User } from '../../core/models';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Users</h1>
        <div class="filters">
          <input type="text" [(ngModel)]="search" placeholder="Search phone or name..."
                 (keyup.enter)="loadUsers()" class="search-input">
          <select [(ngModel)]="roleFilter" (change)="loadUsers()" class="filter-select">
            <option value="">All Roles</option>
            <option value="member">Member</option>
            <option value="gym_partner">Gym Partner</option>
            <option value="admin">Admin</option>
          </select>
          <button class="btn-add" (click)="openCreate()">+ Add User</button>
        </div>
      </div>
      @if (loading()) {
        <app-loading-spinner />
      } @else {
        <app-data-table [columns]="columns" [data]="usersData()" (action)="onAction($event)" />
      }
    </div>

    <!-- Detail / Edit Modal -->
    @if (showModal()) {
      <div class="modal-backdrop" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h2>{{ modalMode() === 'create' ? 'Create User' : modalMode() === 'edit' ? 'Edit User' : 'User Details' }}</h2>
            <button class="close-btn" (click)="closeModal()">✕</button>
          </div>
          <div class="modal-body">
            @if (modalMode() === 'view' && selectedUser()) {
              <div class="detail-grid">
                <div class="detail-item"><span class="label">ID</span><span class="value id-val">{{ selectedUser()!.id }}</span></div>
                <div class="detail-item"><span class="label">Name</span><span class="value">{{ selectedUser()!.full_name }}</span></div>
                <div class="detail-item"><span class="label">Phone</span><span class="value">{{ selectedUser()!.phone }}</span></div>
                <div class="detail-item"><span class="label">Email</span><span class="value">{{ selectedUser()!.email || '—' }}</span></div>
                <div class="detail-item"><span class="label">Role</span><span class="value badge" [style.color]="roleBadge(selectedUser()!.role)">{{ selectedUser()!.role }}</span></div>
                <div class="detail-item"><span class="label">Gender</span><span class="value">{{ selectedUser()!.gender || '—' }}</span></div>
                <div class="detail-item"><span class="label">Active</span><span class="value">{{ selectedUser()!.is_active ? '✅ Yes' : '❌ No' }}</span></div>
                <div class="detail-item"><span class="label">Language</span><span class="value">{{ selectedUser()!.preferred_language }}</span></div>
                <div class="detail-item"><span class="label">Country ID</span><span class="value">{{ selectedUser()!.country_id }}</span></div>
                <div class="detail-item"><span class="label">Joined</span><span class="value">{{ selectedUser()!.created_at | date:'medium' }}</span></div>
              </div>
              <div class="modal-actions">
                <button class="btn-edit" (click)="switchToEdit()">✏️ Edit</button>
                <button class="btn-danger" (click)="deleteFromModal()">🗑 Deactivate</button>
              </div>
            }
            @if (modalMode() === 'edit' || modalMode() === 'create') {
              <div class="form-grid">
                <div class="form-group">
                  <label>Full Name *</label>
                  <input [(ngModel)]="form.full_name" placeholder="Full name">
                </div>
                <div class="form-group">
                  <label>Phone *</label>
                  <input [(ngModel)]="form.phone" placeholder="+962791234567" [disabled]="modalMode() === 'edit'">
                </div>
                <div class="form-group">
                  <label>Email</label>
                  <input [(ngModel)]="form.email" placeholder="email@example.com">
                </div>
                <div class="form-group">
                  <label>Role</label>
                  <select [(ngModel)]="form.role">
                    <option value="member">Member</option>
                    <option value="gym_partner">Gym Partner</option>
                    <option value="admin">Admin</option>
                  </select>
                </div>
                <div class="form-group">
                  <label>Gender</label>
                  <select [(ngModel)]="form.gender">
                    <option value="">Not specified</option>
                    <option value="male">Male</option>
                    <option value="female">Female</option>
                  </select>
                </div>
                @if (modalMode() === 'edit') {
                  <div class="form-group">
                    <label>Active</label>
                    <select [(ngModel)]="form.is_active">
                      <option [ngValue]="true">Active</option>
                      <option [ngValue]="false">Inactive</option>
                    </select>
                  </div>
                }
              </div>
              @if (formError()) { <div class="form-error">{{ formError() }}</div> }
              <div class="modal-actions">
                <button class="btn-cancel" (click)="closeModal()">Cancel</button>
                <button class="btn-save" (click)="save()" [disabled]="saving()">
                  {{ saving() ? 'Saving...' : modalMode() === 'create' ? 'Create User' : 'Save Changes' }}
                </button>
              </div>
            }
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; align-items: center; }
    .search-input, .filter-select {
      background: #111; border: 1px solid #333; border-radius: 8px; padding: 8px 12px;
      color: #fff; font-size: 14px; outline: none;
    }
    .search-input:focus, .filter-select:focus { border-color: #00FF88; }
    .btn-add { background: #00FF88; color: #000; border: none; border-radius: 8px; padding: 8px 16px; font-weight: 700; cursor: pointer; font-size: 14px; white-space: nowrap; }
    .btn-add:hover { opacity: 0.9; }
    .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
    .modal { background: #111; border: 1px solid #222; border-radius: 16px; width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid #222; }
    .modal-header h2 { color: #fff; font-size: 20px; margin: 0; }
    .close-btn { background: none; border: none; color: #888; font-size: 20px; cursor: pointer; }
    .close-btn:hover { color: #fff; }
    .modal-body { padding: 24px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
    .detail-item { display: flex; flex-direction: column; gap: 4px; }
    .label { color: #888; font-size: 12px; font-weight: 600; text-transform: uppercase; }
    .value { color: #fff; font-size: 14px; }
    .id-val { font-size: 11px; color: #666; word-break: break-all; }
    .badge { font-weight: 700; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group label { color: #888; font-size: 12px; font-weight: 600; }
    .form-group input, .form-group select { background: #0a0a0a; border: 1px solid #333; border-radius: 8px; padding: 10px 12px; color: #fff; font-size: 14px; outline: none; }
    .form-group input:focus, .form-group select:focus { border-color: #00FF88; }
    .form-group input:disabled { opacity: 0.5; }
    .form-error { background: rgba(255,59,48,0.1); border: 1px solid rgba(255,59,48,0.3); color: #FF3B30; padding: 8px 12px; border-radius: 8px; font-size: 13px; margin-bottom: 16px; }
    .modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
    .btn-cancel { background: #222; border: 1px solid #333; border-radius: 8px; padding: 10px 20px; color: #888; cursor: pointer; font-size: 14px; }
    .btn-save { background: #00FF88; color: #000; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 700; cursor: pointer; font-size: 14px; }
    .btn-save:disabled { opacity: 0.5; }
    .btn-edit { background: #222; border: 1px solid #00D4FF; border-radius: 8px; padding: 8px 16px; color: #00D4FF; cursor: pointer; font-size: 13px; }
    .btn-danger { background: #222; border: 1px solid #FF3B30; border-radius: 8px; padding: 8px 16px; color: #FF3B30; cursor: pointer; font-size: 13px; }
  `]
})
export class UsersComponent implements OnInit {
  loading = signal(true);
  users = signal<User[]>([]);
  search = '';
  roleFilter = '';
  showModal = signal(false);
  modalMode = signal<'view' | 'edit' | 'create'>('view');
  selectedUser = signal<User | null>(null);
  saving = signal(false);
  formError = signal('');
  form: { full_name: string; phone: string; email: string; role: string; gender: string; is_active: boolean } = {
    full_name: '', phone: '', email: '', role: 'member', gender: '', is_active: true
  };

  columns: TableColumn[] = [
    { key: 'full_name', label: 'Name' },
    { key: 'phone', label: 'Phone' },
    { key: 'role', label: 'Role', type: 'badge', badgeColors: { member: '#00FF88', gym_partner: '#00D4FF', admin: '#FFD60A', super_admin: '#FF3B30' } },
    { key: 'is_active', label: 'Active', type: 'boolean' },
    { key: 'created_at', label: 'Joined', type: 'date' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  usersData = signal<Record<string, unknown>[]>([]);
  private adminService = inject(AdminService);

  ngOnInit(): void { this.loadUsers(); }

  loadUsers(): void {
    this.loading.set(true);
    this.adminService.getUsers(0, 100, this.roleFilter || undefined, this.search || undefined).subscribe({
      next: (data: User[]) => {
        this.users.set(data);
        this.usersData.set(data as unknown as Record<string, unknown>[]);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    if (event.action === 'view') {
      const user = this.users().find(u => u.id === id);
      if (user) { this.selectedUser.set(user); this.modalMode.set('view'); this.showModal.set(true); }
    }
    if (event.action === 'edit') {
      const user = this.users().find(u => u.id === id);
      if (user) { this.openEdit(user); }
    }
    if (event.action === 'delete' && confirm('Deactivate this user?')) {
      this.adminService.deleteUser(id).subscribe(() => this.loadUsers());
    }
  }

  openCreate(): void {
    this.form = { full_name: '', phone: '', email: '', role: 'member', gender: '', is_active: true };
    this.formError.set('');
    this.modalMode.set('create');
    this.showModal.set(true);
  }

  openEdit(user: User): void {
    this.selectedUser.set(user);
    this.form = { full_name: user.full_name, phone: user.phone, email: user.email || '', role: user.role, gender: user.gender || '', is_active: user.is_active };
    this.formError.set('');
    this.modalMode.set('edit');
    this.showModal.set(true);
  }

  switchToEdit(): void {
    const u = this.selectedUser();
    if (u) this.openEdit(u);
  }

  save(): void {
    if (!this.form.full_name || (!this.form.phone && this.modalMode() === 'create')) {
      this.formError.set('Name and phone are required'); return;
    }
    this.saving.set(true);
    if (this.modalMode() === 'create') {
      this.adminService.createUser({
        phone: this.form.phone, full_name: this.form.full_name,
        email: this.form.email || undefined, role: this.form.role, gender: this.form.gender || undefined,
      }).subscribe({ next: () => { this.closeModal(); this.loadUsers(); }, error: (e: { error?: { detail?: string } }) => { this.formError.set(e.error?.detail || 'Failed to create'); this.saving.set(false); } });
    } else {
      const id = this.selectedUser()!.id;
      this.adminService.updateUser(id, {
        full_name: this.form.full_name, email: this.form.email || undefined,
        role: this.form.role, gender: this.form.gender || undefined, is_active: this.form.is_active,
      }).subscribe({ next: () => { this.closeModal(); this.loadUsers(); }, error: (e: { error?: { detail?: string } }) => { this.formError.set(e.error?.detail || 'Failed to update'); this.saving.set(false); } });
    }
  }

  deleteFromModal(): void {
    const u = this.selectedUser();
    if (u && confirm('Deactivate this user?')) {
      this.adminService.deleteUser(u.id).subscribe(() => { this.closeModal(); this.loadUsers(); });
    }
  }

  closeModal(): void { this.showModal.set(false); this.selectedUser.set(null); this.saving.set(false); }

  roleBadge(role: string): string {
    const m: Record<string, string> = { member: '#00FF88', gym_partner: '#00D4FF', admin: '#FFD60A', super_admin: '#FF3B30' };
    return m[role] || '#888';
  }
}
