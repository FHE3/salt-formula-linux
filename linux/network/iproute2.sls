/etc/iproute2/rt_tables.d/rt-tables.conf:
{% if not salt['pillar.get']('linux:network:iproute2:rt-tables:enabled', False) %}
  file.absent
{% else %}
  file.managed:
    - makedirs: True
    - source: salt://linux/files/rt-tables.conf
    - mode: '0644'
    - user: 'root'
    - group: 'root'
    - template: jinja
{% endif %}
