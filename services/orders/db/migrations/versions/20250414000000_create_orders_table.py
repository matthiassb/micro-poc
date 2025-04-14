"""create orders table

Revision ID: 20250414000000
Revises: 
Create Date: 2025-04-14 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import text

# revision identifiers, used by Alembic.
revision = '20250414000000'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # First ensure schema exists
    conn = op.get_bind()
    conn.execute(text("CREATE SCHEMA IF NOT EXISTS orders"))
    conn.execute(text("COMMIT"))  # Explicitly commit the schema creation
    
    # Now create the table within the schema
    op.create_table('orders',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('customer_id', sa.Integer(), nullable=False),
        sa.Column('total_amount', sa.Float(), nullable=False),
        sa.Column('status', sa.String(), nullable=False, server_default='pending'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        schema='orders'
    )
    op.create_index(op.f('ix_orders_id'), 'orders', ['id'], unique=False, schema='orders')
    
    # Verify table exists
    conn = op.get_bind()
    conn.execute(text("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'orders' AND table_name = 'orders'"))


def downgrade():
    op.drop_index(op.f('ix_orders_id'), table_name='orders', schema='orders')
    op.drop_table('orders', schema='orders')
