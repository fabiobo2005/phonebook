package br.com.demo.model;

import org.hibernate.validator.constraints.Length;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import java.util.Date;

/**
 * Class that defines the data model.
 *
 * @author fvilarinho
 * @version 1.0.0
 */
@Entity(name = "phonebook")
public class Phonebook{
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id = null;
    
    @Length(max = 1000)
    private String name = null;
    private String phone = null;
    private Date birthDate = null;

    public Date getBirthDate() {
        return this.birthDate;
    }

    public void setBirthDate(Date birthDate) {
        this.birthDate = birthDate;
    }

    public String getName(){
        return name;
    }
    
    public void setName(String name){
        this.name = name;
    }
    
    public String getPhone(){
        return phone;
    }
    
    public void setPhone(String phone){
        this.phone = phone;
    }
    
    public void setId(Integer id){
        this.id = id;
    }
    
    public Integer getId(){
        return id;
    }
}
