/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Entidades;

/**
 *
 * @author VENEGAS
 */
public class EUsuario {
private int id;
private String usuario;
private String clave;
private String nusuario;
private String email;
private int pid;

    public EUsuario(int id, String usuario, String clave, String nusuario, String email, int pid) {
        this.id = id;
        this.usuario = usuario;
        this.clave = clave;
        this.nusuario = nusuario;
        this.email = email;
        this.pid = pid;
    }

    public EUsuario(String usuario, String clave, String nusuario, String email, int pid) {
        this.usuario = usuario;
        this.clave = clave;
        this.nusuario = nusuario;
        this.email = email;
        this.pid = pid;
    }

    public EUsuario() {
        
    }

    
    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getClave() {
        return clave;
    }

    public void setClave(String clave) {
        this.clave = clave;
    }

    public String getNusuario() {
        return nusuario;
    }

    public void setNusuario(String nusuario) {
        this.nusuario = nusuario;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getPid() {
        return pid;
    }

    public void setPid(int pid) {
        this.pid = pid;
    }


    
    
}
