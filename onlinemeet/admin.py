from .models import Meeting
from django.contrib import admin
from django.contrib.auth.models import Group

admin.site.unregister(Group)


class CustomAdmin(admin.ModelAdmin):
    list_display = ["creator", "title_of_meeting", "created", "updated"]


admin.site.site_header = 'HR Администрация'
admin.site.site_title = 'Стажировка в Банк Центр-инвест Собрание'

admin.site.register(Meeting, CustomAdmin)
