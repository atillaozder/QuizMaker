from django import forms
from django.utils.translation import gettext, gettext_lazy as _
from django.contrib.auth.forms import ReadOnlyPasswordHashField
from django.contrib.auth import get_user_model

User = get_user_model()

class AdminCreationForm(forms.ModelForm):
    """
    A form for creating new users. Includes all the required
    fields, plus a repeated password.
    """
    password1 = forms.CharField(label=_('Password'), widget=forms.PasswordInput)
    password2 = forms.CharField(label=_('Repeat Password'), widget=forms.PasswordInput)

    class Meta:
        model = User
        fields = {
            'email',
        }

    def clean_password2(self):
        # Checks the two password entries match
        password1 = self.cleaned_data.get("password1")
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise forms.ValidationError(_("Mismatch Passwords"))
        return password2

    def save(self, commit=True):
        # Save the provided password in hashed format
        user = super(AdminCreationForm, self).save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user


class AdminChangeForm(forms.ModelForm):
    """
    A form for updating users. Includes all the fields on
    the user, but replaces the password field with admin's
    password hash display field.
    """
    password = ReadOnlyPasswordHashField(
        label='Password',
        help_text=_(
            "Raw passwords are not stored, so there is no way to see this "
            "user's password, but you can change the password using "
            "<a href=\"../password/\">this form</a>."
        ),
    )

    class Meta:
        model = User
        fields = '__all__'

    def clean_password(self):
        # Regardless of what the user provides, return the initial value.
        # This is done here, rather than on the field, because the
        # field does not have access to the initial value
        return self.initial["password"]
