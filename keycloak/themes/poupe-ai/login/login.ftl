<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "header">
        <div style="text-align: center; margin-bottom: 20px;">
            <img src="${url.resourcesPath}/img/logo.png" alt="Poupe.AI Logo" style="width: 120px;"/>
        </div>
        <h1 id="kc-page-title"><span style="color: #ccc;">Poupe.</span>AI</h1>
    </#if>

    <#if section = "form">
        <p style="text-align: center; color: #ccc; margin-bottom: 25px;">
            Controle suas finanças, conquiste seus sonhos. Faça login para começar!
        </p>

        <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
            <div class="${properties.kcFormGroupClass!}">
                <div class="input-icon-wrapper">
                    <img src="${url.resourcesPath}/img/user.svg" alt="Ícone de usuário" class="input-icon" />
                    <input tabindex="1" id="username" class="${properties.kcInputClass!}" name="username" type="text" autofocus autocomplete="off" placeholder="Digite seu email" />
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!}">
                <div class="input-icon-wrapper">
                    <img src="${url.resourcesPath}/img/key.svg" alt="Ícone de chave" class="input-icon" />
                    <input tabindex="2" id="password" class="${properties.kcInputClass!}" name="password" type="password" autocomplete="off" placeholder="Digite sua senha" />
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                <div id="kc-form-options">
                    <#if realm.resetPasswordAllowed>
                        <span><a tabindex="5" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></span>
                    </#if>
                </div>
            </div>

            <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                <input tabindex="4" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit" value="${msg("Entrar")}"/>
            </div>
        </form>

        <div id="kc-registration">
            <span>${msg("Não tem uma conta?")} <a tabindex="6" href="${url.registrationUrl}">${msg("Clique Aqui")}</a></span>
        </div>

        <hr style="border-color: #2c2c2c; margin: 20px 0;">

        <#if realm.password & social.providers?size gt 0>
            <div id="kc-social-providers" class="${properties.kcFormSocialAccountContentClass!} ${properties.kcFormSocialAccountClass!}">
                <ul class="${properties.kcFormSocialAccountListClass!} <#if social.providers?size gt 1>kc-social-providers-ext-area</#if>">
                    <#list social.providers as p>
                         <a id="social-${p.alias}" class="kc-social-provider-button" type="button" href="${p.loginUrl}">
                            <#if p.providerId == 'google'>
                                <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" class="kc-social-provider-logo-svg">
                                    <g><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path><path fill="#FBBC05" d="M10.53 28.41c-.44-1.33-.66-2.77-.66-4.21s.22-2.88.66-4.21l-7.98-6.19C.92 16.46 0 20.12 0 24.2c0 4.08.92 7.74 2.56 10.4l7.97-6.19z"></path><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path><path fill="none" d="M0 0h48v48H0z"></path></g>
                                </svg>
                                <span class="kc-social-provider-name">Fazer login com Google</span>
                            <#else>
                                <i class="${properties.kcCommonLogoIdP!} ${p.providerId}" aria-hidden="true"></i>
                                <span class="${properties.kcFormSocialAccountNameClass!}">${p.displayName}</span>
                            </#if>
                        </a>
                    </#list>
                </ul>
            </div>
        </#if>

    </#if>
</@layout.registrationLayout>