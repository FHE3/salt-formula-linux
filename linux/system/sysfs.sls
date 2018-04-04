{%- from "linux/map.jinja" import system with context %}

linux_sysfs_package:
  pkg.installed:
    - pkgs:
      - sysfsutils
    - refresh: true

/etc/sysfs.d:
  file.directory:
    - require:
      - pkg: linux_sysfs_package

{%- for name, sysfs in system.get('sysfs', {}).iteritems() %}

/etc/sysfs.d/{{ name }}.conf:
  file.managed:
    - source: salt://linux/files/sysfs.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - defaults:
        name: {{ name }}
        sysfs: {{ sysfs|yaml }}
    - require:
      - file: /etc/sysfs.d

  {%- for key, value in sysfs.iteritems() %}
    {%- if key not in ["mode", "owner"] %}
      {%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
      {#- Sysfs cannot be set in docker, LXC, etc. #}
linux_sysfs_write_{{ name }}_{{ key }}:
  module.run:
    - name: sysfs.write
    - key: {{ key }}
    - value: {{ value }}
    - onchanges:
      - file: /etc/sysfs.d/{{ name }}.conf
      {%- endif %}
    {%- endif %}
  {%- endfor %}

{%- endfor %}
